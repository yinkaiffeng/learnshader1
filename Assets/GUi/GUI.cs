using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GUI : MonoBehaviour
{
    // Start is called before the first frame update
    
    private int index;
    private string[] buttonNames = new[] { "fiest", "second", "Third" };
    private bool toggleValue;

    private string areaText = "muti-line text";
    private string singleText = "single-line text";

    private float horizontalValue = 0;
    private float verticalValue = 0;
    private void OnGUI()
    {
        if (GUILayout.Button("Im a button"))
        {
            Debug.Log("HELLO WORLD ");
        }

        index = GUILayout.SelectionGrid(index, buttonNames, 2);
        index = GUILayout.Toolbar(index, buttonNames);
        toggleValue = GUILayout.Toggle(toggleValue, "this is a toggleValue");
        GUILayout.Label("this is Label Text");
        areaText = GUILayout.TextArea(areaText);
        singleText = GUILayout.TextField(singleText);

        horizontalValue = GUILayout.HorizontalSlider(horizontalValue, 0, 100, GUILayout.Width(300));
        verticalValue = GUILayout.VerticalSlider(verticalValue, 0, 100);

    }
}
