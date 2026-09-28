# Smart Virtual Classroom — PostgreSQL, SQLAlchemy et Alembic

Ce paquet fournit la base de données du projet **Smart Virtual Classroom and Intelligent Attendance Management System**. Il comprend les tables académiques, les sessions virtuelles, la présence, la participation, les rapports, l’audit et les tables nécessaires aux extensions IA.

## Contenu

| Fichier | Rôle |
|---|---|
| `app/db/models.py` | 23 modèles SQLAlchemy 2.x, relations, contraintes et enums |
| `app/db/base.py` | Base déclarative importée par Alembic |
| `app/db/session.py` | Moteur PostgreSQL et sessions SQLAlchemy |
| `alembic/env.py` | Configuration des migrations |
| `alembic/versions/0001_initial_schema.py` | Migration initiale du schéma |
| `schema.sql` | SQL PostgreSQL généré depuis les modèles |
| `seed.py` | Données fictives de développement |
| `validate_models.py` | Vérification des tables et relations |
| `requirements.txt` | Dépendances Python |

## Installation

Installez PostgreSQL, créez une base de données vide, puis préparez un environnement virtuel Python :

```bash
createdb smart_classroom
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Définissez ensuite l’URL de connexion. L’exemple ci-dessous est uniquement destiné au développement local :

```bash
export DATABASE_URL='postgresql+psycopg://postgres:postgres@localhost:5432/smart_classroom'
```

En production, utilisez un secret sécurisé et un utilisateur PostgreSQL dédié disposant uniquement des permissions nécessaires.

## Créer le schéma avec Alembic

Depuis le dossier racine :

```bash
alembic upgrade head
```

Pour vérifier les modèles avant la migration :

```bash
python validate_models.py
```

Pour générer une nouvelle migration après une modification des modèles :

```bash
alembic revision --autogenerate -m "describe the change"
alembic upgrade head
```

La migration initiale utilise `Base.metadata.create_all` afin d’installer l’ensemble cohérent des 23 tables. Pour un projet de production déjà en évolution, il est recommandé de conserver ensuite des migrations explicites et réversibles générées puis relues manuellement.

## Données de démonstration

Le script de seed ajoute uniquement des départements et un terme académique fictifs. Il ne crée pas de vrais comptes étudiants et ne doit pas être exécuté sur une base de production :

```bash
python seed.py
```

## Principes importants

Les événements techniques de présence (`attendance_events`) sont conservés séparément du résumé de présence (`session_participants`). Cette séparation permet de recalculer une durée et de gérer les reconnexions sans perdre l’historique.

La participation (`questions` et `responses`) reste distincte de la présence. Une absence de réponse ne constitue pas automatiquement une preuve d’absence ou d’inattention. Les corrections sont conservées dans `attendance_adjustments` avec l’auteur et la raison.

Les tables IA sont préparées pour une implémentation progressive. Les documents doivent être approuvés avant leur utilisation par l’IA. Chaque résumé, question ou recommandation conserve le modèle utilisé, la version du prompt, les sources et le statut de validation humaine lorsque cela est applicable.

Les clés d’API IA ne doivent jamais être placées dans l’application Flutter. Les appels IA doivent passer par le backend, qui doit vérifier l’autorisation de l’utilisateur, filtrer les documents accessibles et enregistrer les sorties produites.

## Entités incluses

Le modèle couvre les domaines suivants : identité et rôles, départements et termes académiques, cours et inscriptions, sessions WebRTC, participants et événements de présence, questions et réponses, corrections, rapports, chat, notifications, audit, documents pédagogiques, transcriptions, résumés, questions de révision, conversations IA, messages IA et recommandations IA.
