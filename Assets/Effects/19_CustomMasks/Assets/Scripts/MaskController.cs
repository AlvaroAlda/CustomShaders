using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskController : MonoBehaviour
{
    [SerializeField] private Transform HaloTransform;
    [SerializeField] private float HaloRotateSpeed;

    private void Start()
    {
        Cursor.visible = false;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = Input.mousePosition;
        HaloTransform.Rotate(0, 0, HaloRotateSpeed * Time.deltaTime);
    }
}
