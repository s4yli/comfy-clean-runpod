# ComfyUI minimal pour Runpod

Image volontairement limitée à ComfyUI et ses dépendances d'exécution. Elle ne
contient ni modèle, ni custom node, ni ComfyUI-Manager, ni Jupyter, ni SSH.

## Construire l'image

```bash
docker build -t votre-compte/comfyui-clean:latest .
docker push votre-compte/comfyui-clean:latest
```

Par défaut, le build prend la version la plus récente de la branche officielle
`master`. Pour rendre un build reproductible, passez un tag ou un commit :

```bash
docker build --build-arg COMFYUI_REF=v0.3.50 -t votre-compte/comfyui-clean:v0.3.50 .
```

## Paramètres du template Runpod

- **Container image** : l'image publiée ci-dessus
- **Container disk** : 10 Go minimum
- **Volume mount path** : `/workspace`
- **Expose HTTP port** : `8188`
- **Container start command** : laisser vide

Les modèles et les données utilisateur sont conservés dans
`/workspace/comfyui`. Le volume doit être assez grand pour les modèles que vous
comptez ajouter.

## Options

Les arguments ajoutés à la commande du conteneur sont transmis à `main.py`.
Exemple : `--preview-method auto`. La variable `COMFYUI_PORT` permet de changer
le port, mais le port HTTP du template doit alors être modifié également.

Le choix par défaut est PyTorch CUDA 12.8. L'URL des roues peut être remplacée
au build avec `PYTORCH_INDEX_URL` si une flotte impose une autre version CUDA.

