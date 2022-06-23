FROM mcr.microsoft.com/dotnet/aspnet:2.1-focal AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:2.1-focal AS build
WORKDIR /src
COPY ["RakGameShopAPI/RakGameShopAPI/RakGameShopAPI.csproj", "RakGameShopAPI/RakGameShopAPI/"]
RUN dotnet restore "RakGameShopAPI/RakGameShopAPI/RakGameShopAPI.csproj"
COPY . .
WORKDIR "/src/RakGameShopAPI/RakGameShopAPI"
RUN dotnet build "RakGameShopAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "RakGameShopAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "RakGameShopAPI.dll"]
