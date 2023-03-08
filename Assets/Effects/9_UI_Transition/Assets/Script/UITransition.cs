using System;
using DG.Tweening;
using Unity.VisualScripting;

namespace ShaderGraphCookBook
{
    using System.Collections;
    using UnityEngine;
    
    public class UITransition : MonoBehaviour
    {
        [SerializeField] private float transitionTime = 2f;
        [SerializeField] private bool loop = false;
        [SerializeField] private Material targetMaterial;
        private readonly int _progressId = Shader.PropertyToID("_Progress");


        IEnumerator Start()
        {
            yield return new WaitForSeconds(0.25f);
            
            if (targetMaterial != null)
            {
                targetMaterial.SetFloat(_progressId, 1);
                
                targetMaterial.
                    DOFloat(0, _progressId, transitionTime).
                    SetLoops(loop? -1:0, LoopType.Yoyo).
                    SetEase(Ease.InOutQuad);
            }
        }
    }
}