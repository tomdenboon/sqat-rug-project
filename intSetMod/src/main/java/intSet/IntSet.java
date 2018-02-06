/**
 * Representation of a finite set of integers.
 * 
 * @invariant getCount() >= 0
 * @invariant getCount() <= getCapacity()
 */
package intSet;


import java.util.ArrayList;
public class IntSet
{
	ArrayList testList;
	int capacity;
	InstrumentCode getCoverage;


	
	/**
	 * Creates a new set with 0 elements.
	 * 
	 * @param capacity
	 *            the maximal number of elements this set can have
	 * @pre capacity >= 0
	 * @post getCount() == 0
	 * @post getCapacity() == capacity
	 */
	public IntSet(int capacity)
	{
		this.getCoverage = new InstrumentCode();
		getCoverage.hit("IntSet","IntSet(int)");
		this.capacity = capacity;
		if(capacity < 0)
		{
			throw new IllegalArgumentException ("Capacity cannot be less than 0") ;
		}
		testList = new ArrayList<Integer>(capacity);
	}

	/**
	 * Test whether the set is empty.
	 * 
	 * @return getCount() == 0
	 */
	public boolean isEmpty() {
		getCoverage.hit("IntSet","isEmpty()");
		return testList.isEmpty();
	}

	/**
	 * Test whether a value is in the set
	 * 
	 * @return exists int v in getArray() such that v == value
	 */
	public boolean has(int value) {
		getCoverage.hit("IntSet","has(int)");
		return testList.contains(value);
	}

	/**
	 * Adds a value to the set.
	 * 
	 * @pre getCount() < getCapacity()
	 * @post has(value)
	 * @post !this@pre.has(value) implies (getCount() == this@pre.getCount() + 1)
	 * @post this@pre.has(value) implies (getCount() == this@pre.getCount())
	 */
	public void add(int value) {
		getCoverage.hit("IntSet","add(int)");
		if(this.getCapacity() <= this.getCount())
		{
			throw new IllegalArgumentException("You have reached capacity");
		}

		if(!this.has(value))
		{
			testList.add(value);
		}


	}

	/**
	 * Removes a value from the set.
	 * 
	 * @post !has(value)
	 * @post this@pre.has(value) implies (getCount() == this@pre.getCount() - 1)
	 * @post !this@pre.has(value) implies (getCount() == this@pre.getCount())
	 */
	public void remove(int value) {
		getCoverage.hit("IntSet","remove(int)");
		for(int i = 0;testList.size() > i;i++)
		{
			if(value == (int)testList.get(i))
			{
				testList.remove(i);
				return;
			}
		}
	}

	/**
	 * Returns the intersection of this set and another set.
	 * 
	 * @param other
	 *            the set to intersect this set with
	 * @return the intersection
	 * @pre other != null
	 * @post forall int v: (has(v) and other.has(v)) implies return.has(v)
	 * @post forall int v: return.has(v) implies (has(v) and other.has(v))
	 */
	public IntSet intersect(IntSet other) {
		getCoverage.hit("IntSet","intersect(intSet.IntSet)");
		if(other == null)
		{
			throw new NullPointerException("Object given is null");
		}

		IntSet newSet = new IntSet(this.getCount()+other.getCount());

		for(Integer item:this.getArray())
		{
			if(other.has(item))
			{
				newSet.add(item);
			}

		}
		return newSet;

	}

	/**
	 * Returns the union of this set and another set.
	 * 
	 * @param other
	 *            the set to union this set with
	 * @return the union
	 * @pre other != null
	 * @post forall int v: has(v) implies return.has(v)
	 * @post forall int v: other.has(v) implies return.has(v)
	 * @post forall int v: return.has(v) implies (has(v) or other.has(v))
	 */
	public IntSet union(IntSet other) {
		getCoverage.hit("IntSet","union(intSet.IntSet)");

		if(other == null)
		{
			throw new NullPointerException("Object given is null");
		}
		IntSet newSet = new IntSet(this.getCount()+other.getCount());

		for(Integer item:this.getArray())
		{
			newSet.add(item);
		}

		for(Integer item:other.getArray())
		{
			newSet.add(item);
		}


		return newSet;
	}

	/**
	 * Returns the difference of this set and another set.
	 * @param other The other set.
	 * @return The difference.
	 * @pre other != null.
	 */
	public IntSet difference(IntSet other){
		getCoverage.hit("IntSet","difference(intSet.IntSet)");
		if (other == null){
			throw new NullPointerException("Given set is null.");
		}
		IntSet newSet = new IntSet(this.getCount());
		for (int value : this.getArray()){
			if (!other.has(value)){
				newSet.add(value);
			}
		}
		return newSet;
	}

	/**
	 * Returns the symmetric difference, or XOR of this set and another.
	 * @param other The other set.
	 * @return The symmetric difference.
	 * @pre other != null.
	 */
	public IntSet symmetricDifference(IntSet other){
		getCoverage.hit("IntSet","symmetricDifference(intSet.IntSet)");
		if (other == null){
			throw new NullPointerException("Given set is null.");
		}
		IntSet newSet = new IntSet(this.getCount()+other.getCount());
		for (int value : this.getArray()){
			if (!other.has(value)){
				newSet.add(value);
			}
		}
		for (int value : other.getArray()){
			if (!this.has(value)){
				newSet.add(value);
			}
		}
		return newSet;
	}

	/**
	 * Returns a representation of this set as an array
	 * 
	 * @post return.length == getCount()
	 * @post forall int v in return: has(v)
	 */
	public int[] getArray() {
		getCoverage.hit("IntSet","getArray()");
		int[] ret = new int[testList.size()];

		for (int i = 0; i < testList.size(); i++)
		{
			ret[i] = (int)testList.get(i);
		}
		return ret;
	}

	/**
	 * Returns the number of elements in the set.
	 */
	public int getCount() {
		getCoverage.hit("IntSet","getCount()");
		return testList.size();
	}

	/**
	 * Returns the maximal number of elements in the set.
	 */
	public int getCapacity() {
		getCoverage.hit("IntSet","getCapacity()");
		return capacity;
	}

	/**
	 * Returns a string representation of the set. The empty set is represented
	 * as {}, a singleton set as {x}, a set with more than one element like {x,
	 * y, z}.
	 */
	public String toString() {
		getCoverage.hit("IntSet","toString()");
		StringBuilder result = new StringBuilder("{");
		if (this.isEmpty()){
			result.append('}');
			return result.toString();
		}
		int[] arr = this.getArray();
		for (int i = 0; i < arr.length; i++){
			result.append(arr[i]);
			if (i == arr.length-1){
				result.append('}');
			} else {
				result.append(", ");
			}
		}
		return result.toString();
	}

}
