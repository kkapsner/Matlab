namespace MedianFilter{
	class Node{
		public:
			// enum values for the relative position to the median node
			static signed char const BEFORE_MEDIAN = -1;
			static signed char const IS_MEDIAN = 0;
			static signed char const AFTER_MEDIAN = 1;
		private:
			/**
			 * *private* constructor with the value of the node
			 * Only List can create new nodes.
			 *
			 * @param double value
			 */
			Node(double value);
			// the nodes value
			double value;
			// the relative position to the median node
			signed char position;
			// the next node in the FIFO list
			Node *next;
			// the next node in the sorted list
			Node *sortedNext;
			// the previous node in the sorted list
			Node *sortedPrev;

		friend class List;
	};

	class List{
		private:
			// the head node of the FIFO list
			Node *head;
			// the tail node of the FIFO list
			Node *tail;
			// the head node of the sorted list
			Node *sortedHead;
			// the median node
			Node *medianNode;
			// size of the list
			unsigned long size;

			/**
			 * performs the shift operation
			 *
			 * @return Node the shifted node
			 */
			Node *internalShift();

			/**
			 * performs the push operation
			 *
			 * @param Node newNode
			 */
			void internalPush(Node *newNode);

		public:
			// constructor
			List();
			// destructor
			~List();

			/**
			 * calculates the median from the median node.
			 * This is fast.
			 *
			 * @return double
			 */
			double getMedian();

			/**
			 * calculates the median from the entire list.
			 * This is slow.
			 *
			 * @return double
			 */
			double getMedian2();

			/**
			 * pushes a value to the list.
			 *
			 * @param double value
			 */
			void push(double value);

			/**
			 * shifts the first node of the list and pushes
			 * a value to the list.
			 * This is slightly faster than calling shift() and
			 * then push().
			 *
			 * @param double value
			 */
			void pushAndShift(double value);

			/**
			 * shifts the first node of the list.
			 */
			void shift();

			/**
			 * Debug function to inspect the list and some of
			 * its properties.
			 */
			void outputInfo();

			/**
			 * Getter for the lists size.
			 *
			 * @retrun long
			 */
			long getSize();
	};

	/**
	 * performs the filtering
	 *
	 * @param double* data pointer to the data array.
	 * @param double* pointer to the filtered data array.
	 *	The two data arrays have to have the same size.
	 * @param long dataSize the size of the data array.
	 *        IMPORTANT: there is no validation for this value!
	 * @param long windowSize the size of the filter window
	 */
	void filter(double* data, double* filtered, long dataSize, long windowSize);
}