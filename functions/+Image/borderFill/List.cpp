#include "List.h"
#ifndef NULL
#define NULL 0
#endif

using namespace borderFill;

Node::Node(int x, int y):
		next(NULL),
		x(x),
		y(y)
		{};

List::List():
	head(NULL),
	tail(NULL)
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

void List::internalPush(Node* newNode){
	if (head == NULL){
		// if the new node is the first in the list
		head = newNode;
		tail = newNode;
	}
	else {
		// append to the FIFO linking
		tail->next = newNode;
		tail = newNode;
	}
}

Node *List::internalShift(){
	Node *toRemove = head;

	head = toRemove->next;

	return toRemove;
}


void List::push(int x, int y){
	Node *newNode = new Node(x, y);
	internalPush(newNode);
}
void List::shift(){
	Node *toRemove = internalShift();
	delete toRemove;
}