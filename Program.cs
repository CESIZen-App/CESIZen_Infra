// Point d'entrée du projet CESIZen_Infra.
// Ce projet sert de support pour les scripts d'infrastructure (SQL, migrations, seeds).
// L'API REST exposée ici est le squelette minimal généré par le template ASP.NET Core ;
// la logique métier se trouve dans CESIZen_API.

var builder = WebApplication.CreateBuilder(args);

// Enregistrement des services MVC et de la documentation Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Swagger disponible uniquement en développement
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Redirection HTTP → HTTPS
app.UseHttpsRedirection();

// Middleware d'autorisation (appliqué avant le routage des contrôleurs)
app.UseAuthorization();

// Mappage des routes vers les contrôleurs
app.MapControllers();

app.Run();
