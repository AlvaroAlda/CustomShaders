using UnityEngine;
using DG.Tweening;
using System.Collections;

public class DissolveController : MonoBehaviour
{
    [SerializeField] private MeshRenderer meshRenderer;

    static readonly int FillID = Shader.PropertyToID("_NoiseFill");

    private IEnumerator Start()
    {
        yield return new WaitForSeconds(0.5f);
        meshRenderer.sharedMaterial.DOFloat(2, FillID, 1).From(-2).SetLoops(-1, LoopType.Yoyo);
    }

}
