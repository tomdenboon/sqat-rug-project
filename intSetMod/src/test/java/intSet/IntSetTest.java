package intSet;

import org.junit.Test;

import static junit.framework.TestCase.assertEquals;
import static org.junit.Assert.*;


public class IntSetTest
{
    //Test the constructor.
    @Test
    public void constructTest()
    {
        //Test for an invalid capacity.
        try {
            IntSet newTest = new IntSet(-1);
        } catch (IllegalArgumentException e){
            assertEquals(e.getMessage(), "Capacity cannot be less than 0");
        }

        //Test normal operations.
        IntSet test = new IntSet(4);
        assertEquals(4,test.getCapacity());
        assertEquals(0,test.getCount());

    }

    //Tests isEmpty method
    @Test
    public void testIsEmpty()
    {
        IntSet newTest = new IntSet(5);
        assertTrue(newTest.isEmpty());
        newTest.add(4);
        assertFalse(newTest.isEmpty());
    }

    //Tests has method
    @Test
    public void testHas()
    {
        IntSet newTest = new IntSet(4);
        assertFalse(newTest.has(4));
        newTest.add(4);
        assertTrue(newTest.has(4));
    }

    //Tests add method.
    @Test
    public void testAdd()
    {
        //Try adding beyond capacity.
        try {
            IntSet newTest = new IntSet(1);
            newTest.add(1);
            newTest.add(2);
        } catch (IllegalArgumentException e){
            assertEquals(e.getMessage(), "You have reached capacity");
        }

        //Test normal adding capabilities.
        IntSet newTest = new IntSet(4);
        newTest.add(1);
        assertTrue(newTest.has(1));
        newTest.add(1);
        assertEquals(1,newTest.getCount());

    }

    //Tests remove method
    @Test
    public void testRemove()
    {
        IntSet newTest = new IntSet(4);
        newTest.add(1);
        newTest.add(2);
        newTest.remove(1);
        assertFalse(newTest.has(1));
        assertEquals(1,newTest.getCount());
        newTest.remove(4);
        assertEquals(1,newTest.getCount());
    }

    //Tests intersection.
    @Test
    public void testIntersect()
    {
        //Test a null pointer error.
        try {
            IntSet newTest = new IntSet(1);
            newTest.intersect(null);
        } catch (NullPointerException e){
            assertEquals(e.getMessage(), "Object given is null");
        }

        //Test normal intersection operations.
        IntSet newTest = new IntSet(3);
        newTest.add(1);
        newTest.add(2);
        newTest.add(3);

        IntSet secondTest = new IntSet(3);
        secondTest.add(3);
        secondTest.add(2);
        secondTest.add(4);

        IntSet returnTest = newTest.intersect(secondTest);

        assertTrue(returnTest.has(3));
        assertTrue(returnTest.has(2));
        //values that do not belong
        assertFalse(returnTest.has(1));
        assertFalse(returnTest.has(4));

        //Tests secondTest Intersect newTest
        IntSet returnTestTwo = secondTest.intersect(newTest);

        //values that are suppose to be there
        assertTrue(returnTestTwo.has(3));
        assertTrue(returnTestTwo.has(2));
        //values that do not belong
        assertFalse(returnTestTwo.has(1));
        assertFalse(returnTestTwo.has(4));

    }

    //Tests if fed null IntSet
    @Test
    public void testUnion()
    {
        //Test for a null pointer exception.
        try {
            IntSet newTest = new IntSet(1);
            newTest.union(null);
        } catch (NullPointerException e){
            assertEquals(e.getMessage(), "Object given is null");
        }

        //Test normal union behaviour.
        IntSet newTest = new IntSet(3);
        newTest.add(1);
        newTest.add(2);
        newTest.add(3);

        IntSet secondTest = new IntSet(3);
        secondTest.add(3);
        secondTest.add(4);
        secondTest.add(5);

        IntSet returnTest = newTest.union(secondTest);

        assertTrue(returnTest.has(1));
        assertTrue(returnTest.has(2));
        assertTrue(returnTest.has(3));
        assertTrue(returnTest.has(4));
        assertTrue(returnTest.has(5));
        //Test for secondTest union newTest
        IntSet returnTestTwo = secondTest.union(newTest);
        //values that need to be in the set
        assertTrue(returnTestTwo.has(1));
        assertTrue(returnTestTwo.has(2));
        assertTrue(returnTestTwo.has(3));
        assertTrue(returnTestTwo.has(4));
        assertTrue(returnTestTwo.has(5));

    }

    //Test difference of two sets.
    @Test
    public void testDifference(){
        IntSet setA = new IntSet(5);
        IntSet setB = new IntSet(5);

        //Test the null pointer exception.
        try {
            setA.difference(null);
        } catch (NullPointerException e){
            assertEquals(e.getMessage(), "Given set is null.");
        }

        //Test normal difference behaviour.
        //empty differences.
        IntSet emptyResult = setA.difference(setB);
        assertTrue(emptyResult.isEmpty());
        //Test with items in sets.
        setA.add(1);
        setA.add(2);
        setA.add(4);
        setB.add(3);
        setB.add(2);
        setB.add(5);

        IntSet result1 = setA.difference(setB);
        assertTrue(result1.has(1));
        assertTrue(result1.has(4));
        assertFalse(result1.has(2));
        assertFalse(result1.has(5));
        assertFalse(result1.has(3));

        IntSet result2 = setB.difference(setA);
        assertTrue(result2.has(3));
        assertTrue(result2.has(5));
        assertFalse(result2.has(2));
        assertFalse(result2.has(1));
        assertFalse(result2.has(4));

    }

    //Test symmetric difference, or XOR.
    @Test
    public void testSymmetricDifference(){
        IntSet setA = new IntSet(5);
        IntSet setB = new IntSet(5);

        //Test null pointer exception.
        try {
            setA.symmetricDifference(null);
        } catch (NullPointerException e){
            assertEquals(e.getMessage(), "Given set is null.");
        }

        //Test empty sets.
        IntSet emptyResult = setA.symmetricDifference(setB);
        assertTrue(emptyResult.isEmpty());

        //Test normal operation.
        setA.add(1);
        setA.add(2);
        setA.add(3);
        setA.add(4);
        setB.add(3);
        setB.add(4);
        setB.add(5);
        setB.add(6);

        IntSet result1 = setA.symmetricDifference(setB);
        assertTrue(result1.has(1));
        assertTrue(result1.has(2));
        assertTrue(result1.has(5));
        assertTrue(result1.has(6));
        assertFalse(result1.has(3));
        assertFalse(result1.has(4));

        setB.add(2);

        IntSet result2 = setB.symmetricDifference(setA);
        assertTrue(result2.has(1));
        assertTrue(result2.has(5));
        assertTrue(result2.has(6));
        assertFalse(result2.has(2));
        assertFalse(result2.has(3));
        assertFalse(result2.has(4));
    }

    //Tests getArray method
    @Test
    public void testGetArray(){
        IntSet set = new IntSet(3);
        assertArrayEquals(new int[]{}, set.getArray());

        set.add(1);
        assertArrayEquals(new int[]{1}, set.getArray());

        set.add(69);
        set.add(54);
        assertArrayEquals(new int[]{1, 69, 54}, set.getArray());
        assertTrue(set.has(1));//Check that the array still has the values after getArray.
        assertTrue(set.has(69));
        assertTrue(set.has(54));
    }

    //Tests toString method
    @Test
    public void testToString(){
        IntSet newTest = new IntSet(3);
        assertEquals(newTest.toString(), "{}");

        newTest.add(69);
        assertEquals(newTest.toString(), "{69}");

        newTest.add(Integer.MAX_VALUE);
        newTest.add(Integer.MIN_VALUE);
        assertEquals(newTest.toString(), "{69, 2147483647, -2147483648}");

        IntSet test2 = new IntSet(5);
        test2.add(1);
        test2.add(2);
        test2.add(3);
        test2.add(2);
        test2.add(1);
        assertEquals(test2.toString(), "{1, 2, 3}");
    }


}
