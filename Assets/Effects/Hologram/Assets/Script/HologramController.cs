using System.Collections;
using UnityEngine;

public class HologramController : MonoBehaviour
{
    [SerializeField] private MeshRenderer meshRenderer;
    [SerializeField] private MinMaxFloat minMaxglitchFrequency;
    [SerializeField] private MinMaxFloat minMaxGlitchStrength;

    static readonly int GlitchStrengthID = Shader.PropertyToID("_GlitchStrength");

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(GlitchCoroutine());
    }

    IEnumerator GlitchCoroutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(1 / minMaxglitchFrequency.RandomValue);
            meshRenderer.sharedMaterial.SetFloat(GlitchStrengthID, minMaxGlitchStrength.RandomValue);
            yield return new WaitForSeconds(0.1f);
            meshRenderer.sharedMaterial.SetFloat(GlitchStrengthID, 0);
        }
    }
}
