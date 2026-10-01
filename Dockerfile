FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY src/Web/SR.Web/SR.Web.csproj src/Web/SR.Web/
RUN dotnet restore src/Web/SR.Web/SR.Web.csproj
COPY src/Web/SR.Web/ src/Web/SR.Web/
RUN dotnet publish src/Web/SR.Web/SR.Web.csproj -c Release --no-restore -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
COPY --from=build /app/publish .
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "SR.Web.dll"]
