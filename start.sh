#!/bin/bash

if command -v brew; then
	echo "Você já possui o homebrew instalado" 
else 
	echo "Homebrew não encontrado. Instalando Homebrew..."
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


  # Adicionar ao .bash_profile do usuário logado
  PROFILE_FILE="/Users/$(whoami)/.bash_profile"
  BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'

  # Adicionar a linha ao .bash_profile se não estiver presente
  if ! grep -Fxq "$BREW_SHELLENV" "$PROFILE_FILE"; then
    echo "" >> "$PROFILE_FILE"
    echo "$BREW_SHELLENV" >> "$PROFILE_FILE"
  fi

  # Executar o comando no shell atual
  eval "$(/opt/homebrew/bin/brew shellenv)"

fi

read -p "Deseja instalar um navegador? (S/N)" install_browser
install_browser=$(echo "$install_browser" | tr '[:upper:]' '[:lower:]')

if ! command -v code &> /dev/null; then
	read -p "Deseja instalar o visual studio code? (S/N)" install_code
	install_code=$(echo "$install_code" | tr '[:upper:]' '[:lower:]')

	if [ "$install_code" = "s" ]; then
		brew install --cask visual-studio-code
	fi
fi

while true; do
	if [ "$install_browser" = "s" ]; then
		browsers=("chrome" "firefox" "opera-gx" "vivaldi")

		exibir_menu() {
			echo "Escolha um navegador para instalar:"
			for ((i=0; i<${#browsers[@]}; i++)); do
				echo "$((i+1)). ${browsers[$i]}"
			done
		}

		exibir_menu

		# Lê a escolha do usuário
		read -p "Digite o número correspondente ao navegador desejado: " escolha

		# Verifica se a escolha é válida
		if [[ $escolha =~ ^[1-4]$ ]]; then
			navegador_escolhido=${browsers[$((escolha-1))]}
			echo "Instalando $navegador_escolhido via Homebrew..."
			brew install --cask $navegador_escolhido
			echo "Instalação concluída."
			break  # Sai do loop enquanto a escolha foi válida
		else
			echo "Opção inválida. Por favor, escolha uma opção de 1 a 4."
		fi
	elif [ "$install_browser" = "n" ]; then
		break
	else
		echo "Resposta inválida. Por favor, responda com S ou N."
	fi
done

# zsh is is installed
if command -v zsh &> /dev/null && [ "$install_zsh" = "s" ]; then
	read -p "Deseja instalar o zsh e torná-lo editor padrão? (S/N)" install_zsh
	install_zsh=$(echo "$install_zsh" | tr '[:upper:]' '[:lower:]')

	if [ "$install_zsh" = "s" ]; then
		brew install zsh
	fi
#zsh isnt installed
else
	# zsh isnt default shell
	if [ "$SHELL" = "/bin/bash" ]; then
		chsh -s $(which zsh)
	fi
fi

read -p "Deseja instalar o Oh-My-ZSH(ohmyz.sh)? (S/N)" install_oh_my_zsh
install_oh_my_zsh=$(echo "$install_oh_my_zsh" | tr '[:upper:]' '[:lower:]')

if [ "$install_oh_my_zsh" = "s" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	read -p "Deseja instalar o tema Spaceship(https://spaceship-prompt.sh) para o ZSH? (S/N)" install_spaceship_theme
	install_spaceship_theme=$(echo "$install_spaceship_theme" | tr '[:upper:]' '[:lower:]')

	if [ "$install_spaceship_theme" = "s" ]; then
		git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
		ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
	fi
fi

read -p "Deseja instalar o XCodesApp? (S/N)" install_xcodes_app
install_xcodes_app=$(echo "$install_xcodes_app" | tr '[:upper:]' '[:lower:]')

if [ "$install_xcodes_app" = "s" ]; then
	brew install --cask xcodes
fi

read -p "Deseja criar uma chave SSH? (S/N)" create_ssh_key
create_ssh_key=$(echo -e "$create_ssh_key" | tr '[:upper:]' '[:lower:]')

if [ "$create_ssh_key" = "s" ]; then
	echo "@@@@@@ ATENÇÃO @@@@@@"
	echo "Se você deseja personalizar, ou criar múltiplas chaves, não use esse script."
	echo "Não altere o local nem o nome da chave"

	read -p "Digite seu email: " ssh_email

	ssh-keygen -t rsa -b 4096 -C "$ssh_email"
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa

	echo "Utilize a chave abaixo no seu github: Settings > SSH and GPG keys > New SSH key"
	echo "LEMBRE-SE: Após adicionar a chave forneça permissões SSO para a chave. "
	cat  ~/.ssh/id_rsa.pub

	config_file=~/.ssh/config

	if [ ! -f "$config_file" ]; then
	    touch "$config_file"
    	chmod 600 "$config_file"

		echo "Host github.com" >> "$config_file"
		echo "  Hostname ssh.github.com" >> "$config_file"
		echo "  Port 443" >> "$config_file"
		echo "Configuração adicionada com sucesso ao arquivo ~/.ssh/config"
	else
		echo "O arquivo $config_file Já existe, você deve adicionar manualmente."
		echo "Adicione o conteúdo com o comando (sudo nano ~/.ssh/config)"
		echo "Host github.com"
		echo "  Hostname ssh.github.com"
		echo "  Port 443"
	fi
fi

read -p "Deseja instalar o Cocoapods? (S/N)" install_pods
install_pods=$(echo "$install_pods" | tr '[:upper:]' '[:lower:]')

if [ "$install_pods" = "s" ]; then
	brew install cocoapods
fi
