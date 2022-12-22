using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[System.Serializable]
public class MinMaxFloat
{
    public float min;
    public float max;
    public float RandomValue
    {
        get
        {
            if (min == max) return min;
            return Random.Range(min, max);
        }
    }
}

[System.Serializable]
public class MinMaxInt
{
    public int min;
    public int max;
    public int RandomValue
    {
        get
        {
            if (min == max) return min;
            return Random.Range(min, max + 1);
        }
    }
}