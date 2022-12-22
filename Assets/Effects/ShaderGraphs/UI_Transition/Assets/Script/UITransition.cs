namespace ShaderGraphCookBook
{
    using System.Collections;
    using UnityEngine;
    using UnityEngine.UI;

    public class UITransition : MonoBehaviour
    {
        [SerializeField] private float transitionTime = 2f;
        [SerializeField] private bool loop = false;
        private Material targetMaterial;
        private readonly int _progressId = Shader.PropertyToID("_Progress");


        void Start()
        {
            targetMaterial = GetComponent<MaskableGraphic>()?.material;
            
            if (targetMaterial != null)
            {
                StartCoroutine(Transition());
            }
        }

 
        IEnumerator Transition()
        {
            float t = 0f;
            while (t < transitionTime)
            {
                float progress = t / transitionTime;

                targetMaterial.SetFloat(_progressId, progress);
                yield return null;

                t += Time.deltaTime;
            }

            targetMaterial.SetFloat(_progressId, 1.001f);

            if (loop)
            {
                yield return new WaitForSeconds(1f);
                yield return Transition();
            }
        }
    }
}