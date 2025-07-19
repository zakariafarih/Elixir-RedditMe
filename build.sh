set -e

export MIX_ENV=prod
mix deps.get --only prod
mix assets.deploy
mix compile
