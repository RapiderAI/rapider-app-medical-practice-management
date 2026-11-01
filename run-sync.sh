
              git clone --depth 1 git@github.com:RapiderAI/rapider-ai-rules.git /tmp/ai-rules-$$
              cp -R /tmp/ai-rules-$$/rapider-app/.agents .
              cp /tmp/ai-rules-$$/rapider-app/AGENTS.md .
              cp /tmp/ai-rules-$$/rapider-app/.cursorrules .
              cp /tmp/ai-rules-$$/rapider-app/.windsurfrules .
              cp /tmp/ai-rules-$$/rapider-app/update-ai-rules.sh .
              chmod +x update-ai-rules.sh
              rm -rf /tmp/ai-rules-$$
              git config user.name "Rapider AI Server"
              git config user.email "server@rapider.ai"
              git add .
              git commit -m "chore: initial AI rules seed"
              git push origin main
            