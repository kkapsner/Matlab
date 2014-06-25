namespace borderFill{
	class Node{
		public:
			int x;
			int y;
		private:
			/**
			 * *private* constructor with the value of the node
			 * Only List can create new nodes.
			 *
			 * @param double value
			 */
			Node(int x, int y);
			// the next node in the FIFO list
			Node *next;

		friend class List;
	};

	class List{
		public:
			// the head node of the FIFO list
			Node *head;
		private:
			// the tail node of the FIFO list
			Node *tail;

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
			 * pushes a value to the list.
			 *
			 * @param double value
			 */
			void push(int x, int y);

			/**
			 * shifts the first node of the list.
			 */
			void shift();
	};
}