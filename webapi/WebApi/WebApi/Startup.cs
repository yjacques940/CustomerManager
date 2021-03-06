﻿using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Swashbuckle.AspNetCore.Swagger;
using WebApi.Data;

namespace WebApi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
	        services.AddCors(options =>
	        {
		        options.AddPolicy("AllowAllOrigin",
			        builder => builder.AllowAnyOrigin()
				        .AllowAnyMethod()
				        .AllowAnyHeader());
	        });

            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_2);
            RegisterServicesAndContext(services);

            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info { Title = "API Massothérapie Carl et Mélanie", Version = "v1" });
            });
        }

        private void RegisterServicesAndContext(IServiceCollection services)
        {
            services.AddDbContext<WebApiContext>(options =>
                options.UseMySql(Configuration.GetConnectionString("WebApiContext")));
            services.AddScoped<IWebApiContext, WebApiContext>();
            services.InjectDataServices();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseSwagger();
                app.UseSwaggerUI(c =>
                {
                    c.SwaggerEndpoint("/swagger/v1/swagger.json", $"API Massothérapie Carl et Mélanie v1");
                    c.RoutePrefix = string.Empty;
                });
            }
            else
            {
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
			app.UseCors("AllowAllOrigin");
            app.UseMvc();
        }
    }
}
