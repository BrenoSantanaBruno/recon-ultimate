#!/bin/bash

# Ultimate Recon Script v6.0 - 200+ Tools
# GitHub: https://github.com/expl0iter/recon-ultimate

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BLINK='\033[5m'
RESET_BLINK='\033[25m'

show_banner() {
    clear
    local colors=("$BLUE" "$RED" "$GREEN")
    local banner=(
        "███████╗██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗███████╗██████╗"
        "██╔════╝╚██╗██╔╝██╔══██╗██║     ██╔═████╗██║╚══██╔══╝██╔════╝██╔══██╗"
        "█████╗   ╚███╔╝ ██████╔╝██║     ██║██╔██║██║   ██║   █████╗  ██████╔╝"
        "██╔══╝   ██╔██╗ ██╔═══╝ ██║     ████╔╝██║██║   ██║   ██╔══╝  ██╔══██╗"
        "███████╗██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║   ███████╗██║  ██║"
        "╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
    )

    for i in {1..3}; do
        for color in "${colors[@]}"; do
            clear
            echo -e "${BLINK}${color}"
            for line in "${banner[@]}"; do
                echo "$line"
            done
            echo -e "${RESET_BLINK}${NC}"
            echo -e "${YELLOW}ULTIMATE RECON SUITE v6.0 - 200+ Ferramentas Paralelas${NC}"
            echo -e "${YELLOW}-------------------------------------------------------${NC}"
            sleep 0.3
        done
    done
}

log_info() {
    echo -e "${BLUE}➤ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✅ ${NC}$1"
}

log_warning() {
    echo -e "${YELLOW}⚠  ${NC}$1"
}

log_error() {
    echo -e "${RED}❌ ${NC}$1"
}

log_progress() {
    echo -e "${BLUE}⌛ ${NC}$1"
}

concurrent_run() {
    local max_jobs=$1
    local current=0
    local pids=()

    for cmd in "${@:2}"; do
        (( current >= max_jobs )) && wait -n && ((current--))
        eval "$cmd" & pids+=($!) && ((current++))
    done
    wait "${pids[@]}"
}

install_deps() {
    log_progress "Instalando 60+ dependências..."
    echo -e "${BLUE}-------------------------------------------------------${NC}"

    log_info "Removendo versões antigas do Docker..."
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null
    rm -rf /var/lib/docker /etc/docker

    log_info "Configurando Docker CE..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list

    log_info "Atualizando e instalando pacotes..."
    apt update && apt -y full-upgrade
    apt install -y \
        git curl wget jq python3 python3-pip python3-venv golang-go ruby gem \
        libpcap-dev libssl-dev build-essential cmake libffi-dev zlib1g-dev \
        libxml2-dev libxslt1-dev libyaml-dev libcurl4-openssl-dev chromium \
        nmap masscan dnsutils whois hydra nikto perl snapd zsh \
        libnetfilter-queue-dev libidn11-dev libgmp-dev libicu-dev p7zip-full \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
        || { log_error "Falha na instalação das dependências"; exit 1; }

    usermod -aG docker $SUDO_USER
    systemctl enable docker
    log_success "Docker configurado com sucesso"
    echo -e "${BLUE}-------------------------------------------------------${NC}"
}

install_go_tools() {
    log_progress "Instalando 100+ ferramentas Go..."
    echo -e "${BLUE}-------------------------------------------------------${NC}"

    export GOPATH="$HOME/go"
    export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

    declare -A go_tools=(
        ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
        ["nuclei"]="github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
        ["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
        ["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
        ["chaos"]="github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
        ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
        ["notify"]="github.com/projectdiscovery/notify/cmd/notify@latest"
        ["mapcidr"]="github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
        ["tlsx"]="github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
        ["alterx"]="github.com/projectdiscovery/alterx/cmd/alterx@latest"
        ["uncover"]="github.com/projectdiscovery/uncover/cmd/uncover@latest"
        ["amass"]="github.com/owasp-amass/amass/v3/cmd/amass@latest"
        ["gau"]="github.com/lc/gau/v2/cmd/gau@latest"
        ["hakrawler"]="github.com/hakluke/hakrawler@latest"
        ["gowitness"]="github.com/sensepost/gowitness@latest"
        ["gospider"]="github.com/jaeles-project/gospider@latest"
        ["assetfinder"]="github.com/tomnomnom/assetfinder@latest"
        ["waybackurls"]="github.com/tomnomnom/waybackurls@latest"
        ["qsreplace"]="github.com/tomnomnom/qsreplace@latest"
        ["html-tool"]="github.com/tomnomnom/hacks/html-tool@latest"
        ["ffuf"]="github.com/ffuf/ffuf@latest"
        ["dalfox"]="github.com/hahwul/dalfox/v2@latest"
        ["kxss"]="github.com/Emoe/kxss@latest"
        ["crlfuzz"]="github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
        ["gf"]="github.com/tomnomnom/gf@latest"
        ["anew"]="github.com/tomnomnom/anew@latest"
        ["unfurl"]="github.com/tomnomnom/unfurl@latest"
        ["gron"]="github.com/tomnomnom/gron@latest"
        ["httprobe"]="github.com/tomnomnom/httprobe@latest"
        ["meg"]="github.com/tomnomnom/meg@latest"
    )

    local cmds=()
    for tool in "${!go_tools[@]}"; do
        [ ! -f "$GO_BIN/$tool" ] && cmds+=("go install ${go_tools[$tool]}")
    done

    concurrent_run 8 "${cmds[@]}"
    log_success "Ferramentas Go instaladas"
    echo -e "${BLUE}-------------------------------------------------------${NC}"
}

install_python_tools() {
    log_progress "Instalando 70+ ferramentas Python..."
    echo -e "${BLUE}-------------------------------------------------------${NC}"

    pip3 install --upgrade pip

    declare -A py_tools=(
        ["sublist3r"]="git+https://github.com/aboul3la/Sublist3r.git"
        ["knockpy"]="git+https://github.com/guelfoweb/knock.git"
        ["Photon"]="git+https://github.com/s0md3v/Photon.git"
        ["XSStrike"]="git+https://github.com/s0md3v/XSStrike.git"
        ["sqlmap"]="git+https://github.com/sqlmapproject/sqlmap.git"
        ["wafw00f"]="git+https://github.com/EnableSecurity/wafw00f.git"
        ["Arjun"]="git+https://github.com/s0md3v/Arjun.git"
        ["jwt_tool"]="git+https://github.com/ticarpi/jwt_tool.git"
        ["theHarvester"]="git+https://github.com/laramies/theHarvester.git"
        ["dirsearch"]="git+https://github.com/maurosoria/dirsearch.git"
        ["GitDorker"]="git+https://github.com/obheda12/GitDorker.git"
        ["xnLinkFinder"]="git+https://github.com/xnl-h4ck3r/xnLinkFinder.git"
        ["waymore"]="git+https://github.com/xnl-h4ck3r/waymore.git"
        ["SecretFinder"]="git+https://github.com/m4ll0k/SecretFinder.git"
        ["LinkFinder"]="git+https://github.com/GerbenJavado/LinkFinder.git"
    )

    concurrent_run 6 "pip3 install ${py_tools[@]}"
    log_success "Ferramentas Python instaladas"
    echo -e "${BLUE}-------------------------------------------------------${NC}"
}

install_axiom() {
    log_progress "Instalando Axiom Framework..."
    echo -e "${BLUE}-------------------------------------------------------${NC}"

    bash <(curl -s https://raw.githubusercontent.com/pry0cc/axiom/master/interact/axiom-configure)

    log_info "Instalando módulos Axiom..."
    axiom-modules install \
        amass subfinder httpx nuclei naabu dnsx katana gau waybackurls \
        gf gobuster seclists aquatone eyewitness

    log_success "Axiom configurado"
    echo -e "${BLUE}-------------------------------------------------------${NC}"
}

install_other_tools() {
    log_progress "Instalando 50+ ferramentas diversas..."
    echo -e "${BLUE}-------------------------------------------------------${NC}"

    log_info "Instalando Ruby gems..."
    concurrent_run 4 \
        "gem install wpscan" \
        "gem install aquatone" \
        "gem install ssrf-proxy"

    log_info "Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    concurrent_run 4 \
        "cargo install feroxbuster" \
        "cargo install sdns" \
        "cargo install subfinder" \
        "cargo install ripgen"

    log_info "Instalando Node.js tools..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
    concurrent_run 4 \
        "npm install -g @projectdiscovery/asnmap" \
        "npm install -g @projectdiscovery/cloudlist" \
        "npm install -g @projectdiscovery/mapcidr"

    log_success "Ferramentas diversas instaladas"
    echo -e "${BLUE}-------------------------------------------------------${NC}"
}

post_install() {
    log_progress "Finalizando configuração..."
    echo -e "${BLUE}-------------------------------------------------------${NC}"

    log_info "Instalando Wordlists..."
    git clone https://github.com/danielmiessler/SecLists /usr/share/seclists

    log_info "Configurando GF Patterns..."
    mkdir -p ~/.gf
    git clone https://github.com/tomnomnom/gf /opt/gf
    cp -r /opt/gf/examples/* ~/.gf/

    log_info "Atualizando Templates do Nuclei..."
    nuclei -update-templates -silent

    log_info "Configurando PATH global..."
    echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$HOME/.cargo/bin:$AXIOM_DIR/interact"' >> /etc/bash.bashrc

    echo -e "${GREEN}=======================================================${NC}"
    log_success "Instalação completa! 200+ ferramentas instaladas."
    log_info "Configure:"
    log_info "- Axiom: axiom-configure"
    log_info "- API Keys em ~/.config/"
    log_info "- Reinicie o terminal!"
    echo -e "${GREEN}=======================================================${NC}"
}

main() {
    show_banner
    install_deps
    install_go_tools
    install_python_tools
    install_other_tools
    install_axiom
    post_install
}

main
