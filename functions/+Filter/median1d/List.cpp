#include "iostream"
#include "List.h"
#ifndef NULL
#define NULL 0
#endif

using namespace MedianFilter;

Node::Node(double value):
		next(NULL),
		sortedNext(NULL),
		sortedPrev(NULL),
		value(value),
		position(0)
		{};

List::List():
	head(NULL),
	tail(NULL),
	sortedHead(NULL),
	medianNode(NULL),
	size(0)
	{};

List::~List(){
	Node *current;
	// free all nodes
	current = head;
	while(current != NULL){
		Node *c = current;
		current = current->next;
		delete c;
	}
}

double List::getMedian2(){
	if (size == 0){
		return 0;
	}
	if (size == 1){
		return sortedHead->value;
	}
	Node *current;
	current = sortedHead;
	unsigned int i = 0;
	while (i < size){
		current = current->sortedNext;
		i += 2;
	}
	if (i == size){
		return (
			current->value + current->sortedPrev->value
		) / 2.;
	}
	else {
		return current->sortedPrev->value;
	}
}

double List::getMedian(){
	if (size % 2 == 0){
		return (
			medianNode->value + medianNode->sortedPrev->value
		) / 2.;
	}
	else {
		return medianNode->value;
	}
}

void List::internalPush(Node* newNode){
	double value = newNode->value;

	size++;

	if (size == 1){
		// if the new node is the first in the list
		head = newNode;
		tail = newNode;
		medianNode = newNode;
		sortedHead = newNode;
		newNode->position = 0;
	}
	else {
		// append to the FIFO linking
		tail->next = newNode;
		tail = newNode;

		// find right position in sorted linking
		Node *current;
		current = sortedHead;

		bool run = true;
		while (run){
			if (current->value >= value){
				// found correct position

				if (current->sortedPrev == NULL){
					// if current is the sortedHead redirect
					// to the new node
					sortedHead = newNode;
				}
				else {
					current->sortedPrev->sortedNext = newNode;
				}
				newNode->sortedPrev = current->sortedPrev;
				newNode->sortedNext = current;
				current->sortedPrev = newNode;

				// set the relative position to the median node
				// for the new node
				if (current->position == Node::AFTER_MEDIAN){
					newNode->position = Node::AFTER_MEDIAN;
				}
				else {
					newNode->position = Node::BEFORE_MEDIAN;
				}
				run = false;
			}
			else if (current->sortedNext == NULL){
				// there was no node with a bigger value
				// --> append
				current->sortedNext = newNode;
				newNode->sortedPrev = current;
				newNode->position = Node::AFTER_MEDIAN;
				run = false;
			}

			current = current->sortedNext;
		}
	}

	// move median node if neccessary
	switch (newNode->position){
		case Node::BEFORE_MEDIAN:
			if (size % 2 == 1){
				medianNode->position = Node::AFTER_MEDIAN;
				medianNode = medianNode->sortedPrev;
				medianNode->position = Node::IS_MEDIAN;
			}
			break;
		case Node::AFTER_MEDIAN:
			if (size % 2 == 0){
				medianNode->position = Node::BEFORE_MEDIAN;
				medianNode = medianNode->sortedNext;
				medianNode->position = Node::IS_MEDIAN;
			}
			break;
	}
}

Node *List::internalShift(){
	Node *toRemove = head;

	head = toRemove->next;

	if (toRemove->sortedNext != NULL){
		toRemove->sortedNext->sortedPrev = toRemove->sortedPrev;
	}
	if (toRemove->sortedPrev != NULL){
		toRemove->sortedPrev->sortedNext = toRemove->sortedNext;
	}
	else {
		sortedHead = toRemove->sortedNext;
	}
	size--;

	// move median node if neccessary
	switch (toRemove->position){
		case Node::BEFORE_MEDIAN:
			if (size % 2 == 0){
				medianNode->position = Node::BEFORE_MEDIAN;
				medianNode = medianNode->sortedNext;
				medianNode->position = Node::IS_MEDIAN;
			}
			break;
		case Node::IS_MEDIAN:
			if (size % 2 == 0){
				medianNode = toRemove->sortedNext;
				medianNode->position = Node::IS_MEDIAN;
			}
			else {
				medianNode = toRemove->sortedPrev;
				medianNode->position = Node::IS_MEDIAN;
			}
			break;
		case Node::AFTER_MEDIAN:
			if (size % 2 == 1){
				medianNode->position = Node::AFTER_MEDIAN;
				medianNode = medianNode->sortedPrev;
				medianNode->position = Node::IS_MEDIAN;
			}
			break;
	}

	return toRemove;
}


void List::push(double value){
	Node *newNode = new Node(value);
	internalPush(newNode);
}
void List::pushAndShift(double value){
	Node *newNode = internalShift();
	// recycle the shifted Node
	newNode->value = value;
	newNode->next = NULL;
	newNode->sortedNext = NULL;
	newNode->sortedPrev = NULL;
	newNode->position = 0;
	internalPush(newNode);
}
void List::shift(){
	Node *toRemove = internalShift();
	delete toRemove;
}

void List::outputInfo(){
	std::cout << std::endl << "Size: " << size << std::endl;
	if (size != 0){
		std::cout << "Main chain: ";
		Node *current = head;
		while (current != NULL){
			std::cout << current->value << ' ';
			current = current->next;
		}
		std::cout << std::endl << "Sorted chain: ";

		current = sortedHead;
		while (current != NULL){
			if (current == medianNode){
				std::cout << ">" << current->value << "< ";
			}
			else {
				std::cout << current->value << ' ';
			}
			current = current->sortedNext;
		}
		std::cout << std::endl
			<< "Median:  " << getMedian()  << std::endl
			<< "Median2: " << getMedian2()
			<< std::endl << std::endl;
	}

}

long List::getSize(){
	return size;
}


void MedianFilter::filter(
	double* data,
	double* filtered,
	long dataSize,
	long windowSize
){
	// double* filtered = new double[dataSize];
	// number of data points on the left of the current
	// data point
	long leftWindow = windowSize / 2;
	// number of data points on the right of the current
	// data point BUT including the data point itself
	long rightWindow = windowSize - leftWindow;
	List list;

	if (dataSize < leftWindow){
		// if the the filter window will allways include
		// all data points

		// fill list
		for (long i = 0; i < dataSize; i++){
			list.push(data[i]);
		}

		// get median
		double median = list.getMedian();

		// assign this value to all filtered data points
		for (long i = 0; i < dataSize; i++){
			filtered[i] = median;
		}
	}
	else if (dataSize < windowSize){
		// if the filter window will always hit one of
		// the borders

		// initialise list
		for (long i = 0; i < rightWindow - 1; i++){
			list.push(data[i]);
		}

		// until filter window hits the end
		for (long i = 0; i < dataSize - rightWindow + 1; i++){
			list.push(data[i + rightWindow - 1]);
			filtered[i] = list.getMedian();
		}

		// until filter window leaves the beginning
		for (long i = dataSize - rightWindow + 1; i < leftWindow + 1; i++){
			filtered[i] = list.getMedian();
		}

		// until the end of the data
		for (long i = leftWindow + 1; i < dataSize; i++){
			list.shift();
			filtered[i] = list.getMedian();
		}

	}
	else {
		// if the filter window fits into the data completely

		// initialise list
		for (long i = 0; i < rightWindow - 1; i++){
			list.push(data[i]);
		}

		// until filter window leaves the beginning
		for (long i = 0; i < leftWindow + 1; i++){
			list.push(data[i + rightWindow - 1]);
			filtered[i] = list.getMedian();
		}

		// until filter window hits the end
		for (long i = leftWindow + 1; i < dataSize - rightWindow + 1; i++){
			list.pushAndShift(data[i + rightWindow - 1]);
			filtered[i] = list.getMedian();
		}

		//until the end of the data
		for (long i = dataSize - rightWindow + 1; i < dataSize; i++){
			list.shift();
			filtered[i] = list.getMedian();
		}
	}
}