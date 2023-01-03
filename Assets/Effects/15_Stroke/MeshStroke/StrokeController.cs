using UnityEngine;
using UnityEngine.EventSystems;

public class StrokeController : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler 
{
    [SerializeField] MeshRenderer meshRenderer;


    public void OnPointerEnter(PointerEventData eventData)
    {
        meshRenderer.sharedMaterial.SetFloat("_StrokeOffset", 0.02f);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        meshRenderer.sharedMaterial.SetFloat("_StrokeOffset", 0);
    }

    private void Start()
    {
        meshRenderer.sharedMaterial.SetFloat("_StrokeOffset", 0);
    }  
}
