using UnityEngine;
using DG.Tweening;

public class PixelatedParticlesController : MonoBehaviour
{
    [SerializeField] private ParticleSystem particles;
    [SerializeField] private MinMaxFloat minMaxResolution;
    [SerializeField] private float duration;

    static readonly int ResolutionID = Shader.PropertyToID("_Resolution");

    private void Start()
    {
        var particleRenderer = particles.GetComponent<Renderer>();
        particleRenderer.sharedMaterial.DOFloat(minMaxResolution.max, ResolutionID, duration).From(minMaxResolution.min).SetLoops(-1, LoopType.Yoyo);
    }
}
