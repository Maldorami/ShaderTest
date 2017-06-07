using UnityEngine;

//[ExecuteInEditMode]
public class CurvedManager : MonoBehaviour {

    public bool bend = false;
    public float horizon = 0.0f;
    public float attenuate = 0f;
    public float spread = 0f;
    int tmp;

    private void Update()
    {
        tmp = bend? 1 : 0;
        Shader.SetGlobalInt("_bend", tmp);
        Shader.SetGlobalFloat("_SPREAD", spread);
        Shader.SetGlobalFloat("_ATTENUATE", attenuate);
        Shader.SetGlobalFloat("_HORIZONOFFSET", horizon);
    }

    private void OnDisable()
    {
        Shader.SetGlobalFloat("_bend", 0);
        Shader.SetGlobalFloat("_ATTENUATE", 0);
        Shader.SetGlobalFloat("_SPREAD", 0);
        Shader.SetGlobalFloat("_HORIZONOFFSET", 0);
    }

}
