using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    private const string HORIZONTAL = "Horizontal";
    private const string VERTICAL = "Vertical";
    private const string MOUSE_X = "Mouse X";
    private const string MOUSE_Y = "Mouse Y";

    private float horizontalInput, verticalInput, mouseInputX, mouseInputY, currentRotationX, currentRotationY;

    [SerializeField]
    private float moveSpeed;

    [SerializeField]
    private float rotationSpeed;

    private void Start()
    {
        currentRotationX = transform.eulerAngles.x;
        currentRotationY = transform.eulerAngles.y;
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        GetInput();
        HandleTranslation();
        HandleRotation();
    }

    private void GetInput()
    {
        horizontalInput = Input.GetAxis(HORIZONTAL);
        verticalInput = Input.GetAxis(VERTICAL);
        mouseInputX = Input.GetAxis(MOUSE_X);
        mouseInputY = Input.GetAxis(MOUSE_Y);
    }

    private void HandleTranslation()
    {
        var moveVector = new Vector3(horizontalInput, 0f, verticalInput);
        transform.Translate(moveVector.normalized * Time.deltaTime * moveSpeed);
    }
    private void HandleRotation()
    {
        float yaw = mouseInputX * Time.deltaTime * rotationSpeed;
        currentRotationY += yaw;

        float pitch = mouseInputY * Time.deltaTime * rotationSpeed;
        currentRotationX -= pitch;
        currentRotationX = Mathf.Clamp(currentRotationX, -90, 90);
        transform.localRotation = Quaternion.Euler(currentRotationX, currentRotationY, 0);
    }

}
