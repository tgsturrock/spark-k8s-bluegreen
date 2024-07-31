# ELE796 Lab4

##Images Docker pour Spark

Ce dépôt fournit des images Docker pour les versions 3.2.0 et 3.2.1 d'Apache Spark. Les images Docker sont construites en utilisant les dossiers fournis, qui contiennent les fichiers de configuration nécessaires et les archives sources.
Structure des Répertoires

Le dépôt contient les répertoires suivants :

    spark3.2.0 : Contient les fichiers et configurations pour construire l'image Docker pour Spark 3.2.0.
    spark3.2.1 : Contient les fichiers et configurations pour construire l'image Docker pour Spark 3.2.1.

Chaque répertoire inclut les fichiers suivants :

    common.sh : Un script avec des commandes de configuration communes utilisées dans les Dockerfiles.
    Dockerfile : Le Dockerfile utilisé pour construire l'image Docker.
    hadoop-3.3.1.tar.gz : L'archive Hadoop 3.3.1 requise par Spark.
    spark-3.2.0-bin-hadoop2.7.tgz (ou spark-3.2.1-bin-hadoop2.7.tgz) : L'archive de distribution binaire de Spark 3.2.0 (ou 3.2.1).
    spark-defaults.conf : Le fichier de configuration Spark utilisé pour définir les propriétés par défaut de Spark.
    spark-master : Un script pour démarrer le nœud maître Spark.
    spark-worker : Un script pour démarrer le nœud worker Spark.

##Fichier lab4.sh

Le script lab4.sh est utiliser pour automatiser le déploiement et la mise à jour de Spark.Voici un aperçu des fonctionnalités de ce script :

    Définition des chemins des fichiers YAML : Les chemins vers les fichiers YAML de déploiement et de service sont définis pour les versions Blue et Green de Spark.

    Validation des déploiements : Le script vérifie que les déploiements du maître et des workers Spark sont correctement mis en place et ont le nombre souhaité de réplicas.

    Validation du service : Le script vérifie que le service Spark Master est correctement configuré et accessible.

    Déploiement de la version Blue : Le script applique les fichiers YAML pour déployer la version Blue de Spark, puis valide le déploiement et le service associés.

    Validation des Jobs Spark : Un job Spark de test est exécuté pour s'assurer que le cluster Spark fonctionne correctement.

    Déploiement de la version Green : Le script applique les fichiers YAML pour déployer la version Green de Spark et valide les déploiements.

    Changement de la version du service : Le service est mis à jour pour pointer vers la version Green de Spark.

    Nettoyage de la version Blue : Les ressources de la version Blue sont supprimées pour libérer de l'espace et éviter les conflits.

    Validation de la version Green : Le script vérifie que le job Spark fonctionne correctement avec la version Green.

    Nettoyage de l'environnement : Les ressources liées à la version Green et les services associés sont supprimés pour maintenir un environnement propre.

Le script assure une transition fluide entre les versions Blue et Green de Spark, tout en validant chaque étape pour garantir un déploiement réussi.
Le script termine en nettoyant l'environnement de travail en supprimant les ressources et services.
