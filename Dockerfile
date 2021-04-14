FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine AS build
WORKDIR /app

# Step 01 # set sonarcloud variables.
ARG SONAR_PROJECT_KEY=claudiospinelli93_MySonarCloud
ARG SONAR_OGRANIZAION_KEY=claudiospinelli93
ARG SONAR_HOST_URL=https://sonarcloud.io
ARG SONAR_TOKEN=790820aec3f5b4ba4ea6405f93889040659ff3b5

# Step 02 # installs tools to use dotnet-sonnarscanner and reportgenerator.
RUN mkdir -p /usr/share/man/man1
RUN apk update && apk add openjdk11
RUN dotnet tool install --global dotnet-sonarscanner --version 5.1.0
RUN dotnet tool install dotnet-reportgenerator-globaltool --version 4.8.4 --tool-path /tools
ENV PATH="$PATH:/root/.dotnet/tools"

# copy csproj and restore as distinct layers.
COPY MySonarCloud.sln ./
COPY src/ ./src/
COPY test/ ./test/

# copy everything else and build app
RUN dotnet restore MySonarCloud.sln

# Step 03 # run test unit and generates the coverage file.
RUN dotnet test ./test/Api.Test/Api.Test.csproj /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:Exclude="[xunit.*]*%2c[StackExchange.*]*"; exit 0
RUN dotnet test ./test/Service.Test/Service.Test.csproj /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura /p:Exclude="[xunit.*]*%2c[StackExchange.*]*"; exit 0

# Step 04 # run reportgenerator to unify the files and save to the testresult folder.
RUN /tools/reportgenerator MySonarCloud.sln "-reports:./test/Api.Test/coverage.cobertura.xml;./test/Service.Test/coverage.cobertura.xml;" "-targetdir:./testresult" "-reporttypes:SonarQube;"

# finalize the build
RUN dotnet build-server shutdown

# Step 05 # start sonarscanner to send data to sonarcloud.
RUN dotnet sonarscanner begin \
  /k:"$SONAR_PROJECT_KEY" \
  /o:"$SONAR_OGRANIZAION_KEY" \
  /d:sonar.host.url="$SONAR_HOST_URL" \
  /d:sonar.login="$SONAR_TOKEN" \
  /d:sonar.coverageReportPaths=./testresult/SonarQube.xml

RUN dotnet publish -c Release -o out

# Step 06 # end of sonnarscan to send data to sonarcloud.
RUN dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
WORKDIR /app
COPY --from=build /app/testresult ./testresult
COPY --from=build /app/out .

ENTRYPOINT ["dotnet", "Api.dll"]