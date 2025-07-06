
#!/bin/bash


echo "🚀 Démarrage du setup Laravel conteneurisé..."

# Copier .env si nécessaire
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✅ Fichier .env créé à partir de .env.example"
else
  echo "ℹ️ Fichier .env déjà présent"
fi

# Lancer les conteneurs Docker (build si besoin)
docker-compose up -d --build


echo "📦 Installation des dépendances PHP..."
docker-compose exec app composer install

echo "📦 Installation des dépendances JS... et ⚙️ Compilation des assets front-end..."
docker-compose run --rm frontend sh -c "npm install && npm run build"


echo "🔐 Génération de la clé Laravel..."
docker-compose exec app php artisan key:generate

echo "🗄️ Lancer les migrations et seeders..."
docker-compose exec app php artisan migrate --seed

echo "🧹 Vider les caches Laravel..."
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
docker-compose exec app php artisan cache:clear

echo "✅ Setup terminé, ton application est prête !"
echo "👉 Ouvre http://localhost:8000 dans ton navigateur"
