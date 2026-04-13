package com.example.demo.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.oas.models.Components;
import io.swagger.oas.models.OpenAPI;
import io.swagger.oas.models.info.Contact;
import io.swagger.oas.models.info.Info;
import io.swagger.oas.models.info.License;
import io.swagger.oas.models.security.SecurityRequirement;
import io.swagger.oas.models.security.SecurityScheme;
import io.swagger.oas.models.servers.Server;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class OpenAPIConfig {
    
    private String devUrl="http://localhost:9090/";;

    
    private String prodUrl="http://localhost:9090/";

    public SecurityScheme createApiKeyScheme() {
        return new SecurityScheme().type(SecurityScheme.Type.HTTP)
                .bearerFormat("JWT")
                .scheme("bearer");
    }
    @Bean
    public OpenAPI myOpenAPI() {
        Server devServer = new Server();
        devServer.setUrl(devUrl);
        devServer.setDescription("Server URL in Development environment");

        Server prodServer = new Server();
        prodServer.setUrl(prodUrl);
        prodServer.setDescription("Server URL in Production environment");

        Contact contact = new Contact();
        contact.setEmail("contact@pasanabeysekara.com");
        contact.setName("Pasan Abeysekara");
        contact.setUrl("https://www.pasanabeysekara.com");

        License mitLicense = new License().name("MIT License").url("https://choosealicense.com/licenses/mit/");

        Info info = new Info()
                .title("Demo Service API")
                .version("1.0")
                .contact(contact)
                .description("This API exposes endpoints to manage demo.").termsOfService("https://www.pasanabeysekara.com")
                .license(mitLicense);
        Components security = new Components().addSecuritySchemes("Bearer Authentication", createApiKeyScheme());
        return new OpenAPI()
                .addSecurityItem(new SecurityRequirement().addList("Bearer Authentication"))
                .components(security)
                .info(info)
                .servers(List.of(devServer, prodServer));
    }
}
