using UnityEngine;

public class Liquid : MonoBehaviour
{
    [SerializeField] float maxWaveSize = 0.3f; 
    [SerializeField] float k = 1f; 
    [SerializeField] float waveSize = 0f;
    [SerializeField] float waveSpeed = 0f;
    [SerializeField] Vector3 waveDirection = new Vector3(1f, 0f, 0f);
    [SerializeField] float waveSizeInfluenceByMove = 0.001f; 
    [SerializeField] float waveDirectionInfluenceByMove = 10f;
    
    MeshRenderer meshRenderer;
    Material material;
    Vector3 position;
    Vector3 previousPosition;
    
    private static readonly int WaveDirection = Shader.PropertyToID("_WaveDirection");
    private static readonly int WaveSize = Shader.PropertyToID("_WaveSize");

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        material = meshRenderer.material;
    }

    void Update()
    {
        previousPosition = position;
        position = transform.position;

        var dt = Time.deltaTime;
        var diff = position - previousPosition;
        
        waveSize += waveSizeInfluenceByMove * diff.magnitude / dt;
        if (waveSize > maxWaveSize) waveSize = maxWaveSize;
        
        waveSpeed = -waveSize * k;
        waveSize += waveSpeed * dt;

        if (position != previousPosition)
        {
            diff.y = 0f;
            waveDirection = Vector3.Lerp(waveDirection, diff.normalized, waveDirectionInfluenceByMove * Time.deltaTime).normalized;
            material.SetVector(WaveDirection, waveDirection);
        }

        material.SetFloat(WaveSize, waveSize);
    }
}
