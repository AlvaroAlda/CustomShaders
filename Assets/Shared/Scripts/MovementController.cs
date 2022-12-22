using UnityEngine;
using DG.Tweening;

public class MovementController : MonoBehaviour
{
    [SerializeField] private float amount;
    [SerializeField] private float duration;
    [SerializeField] private Vector3 direction;


    private void Start()
    {
        transform.DOMove(direction * amount, duration).SetRelative().SetLoops(-1, LoopType.Yoyo);
    }
}
