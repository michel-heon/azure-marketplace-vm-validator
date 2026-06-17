# RU-CTT (FR)

En tant qu’éditeur Marketplace,
je veux une boîte à outils réutilisable de conformité VM,
afin de valider la certification indépendamment des tests applicatifs.

## Critères d’acceptation

- Je peux exécuter `scripts/ctt.sh validate`, `tests`, `test <name>` et `list`.
- Les contrôles s’exécutent à distance via Azure Run Command.
- Les tests de conformité sont séparés des smoke tests applicatifs.
