#!/bin/bash

echo "🔒 Vérification et masquage du fichier .env..."
if ! grep -qxF '.env' .gitignore; then
  echo '.env' >> .gitignore
  echo "✅ Ajout de .env dans .gitignore"
else
  echo ".env est déjà dans .gitignore"
fi

echo "✅ Vérification de la présence de .env.example..."
if [ ! -f .env.example ]; then
  cp .env .env.example
  # Supprimer les valeurs sensibles de .env.example
  sed -i -E 's/=.*/=/' .env.example
  echo "✅ Fichier .env.example créé sans valeurs sensibles"
else
  echo ".env.example existe déjà"
fi

echo "🔁 Nettoyage des dossiers lourds (hors Git)....."
rm -rf vendor node_modules storage/logs/*


echo "📦 Réinstallation des dépendances PHP (via Docker)..."
docker-compose exec app composer install

echo "⚙️ Compilation des assets front-end (prod)..."
docker-compose run --rm frontend sh -c "npm run build"



echo "🧹 Vidage des caches Laravel..."
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
docker-compose exec app php artisan cache:clear

echo "✅ Projet nettoyé, compilé, prêt à être poussé 🚀"
