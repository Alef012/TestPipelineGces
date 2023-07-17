FROM ruby:3.0.4

# Atualizar repositórios e instalar dependências
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev

# Instalar Node.js 16.18.x


RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn


RUN apt-get install -y libpq-dev

# Definir o diretório de trabalho
WORKDIR /app

COPY Gemfile Gemfile.lock ./
# Copiar os arquivos do projeto para o contêiner
COPY . /app

# Instalar as dependências do projeto
RUN  bundle install &&\
    npm install && \
    yarn && \
    gem install mailcatcher --no-document

# Expor a porta
EXPOSE 3000
EXPOSE 1025
EXPOSE 1080

CMD ["sh", "-c", "rails db:create db:migrate && mailcatcher --ip=0.0.0.0 & && rails server -b 0.0.0.0 && bundle exec sidekiq"]