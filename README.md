# cloud-native-app

### Building Cloud-Native Java(Spring Boot) Applications with Kubernetes & Istio: A Complete Guide

1. Introduction

   In the cloud-first world, Kubernetes has become the de facto standard for container orchestration, and Istio enhances
   it by providing powerful service mesh capabilities. This guide will walk you through building a cloud-native Java
   application, containerizing it, deploying it on Kubernetes, and securing, monitoring, and managing it using Istio.

    What You’ll Learn:
    ✅ How to develop a microservices-based Java app
    ✅ How to containerize and deploy it on Kubernetes
    ✅ How to enhance it with Istio (Traffic Routing, Security, Observability)

2. Prerequisites
   Before we dive in, ensure you have the following tools installed:
   * Java 17+ (for Spring Boot)
   * Docker (for containerization)
   * Kubernetes (Minikube or k3s) (for local testing)
   * Kubectl (for managing Kubernetes clusters)
   * Helm (for installing Istio)
   * Istio CLI (istioctl)
   * Postman or curl (for API testing)

3. Step 1: Create a Simple Cloud-Native Java App
   Let’s create a simple Spring Boot Microservice with REST endpoints.

3.1 Create a Spring Boot Project
Use Spring Initializr with the following dependencies:

    ✅ Spring Web
    ✅ Spring Boot Actuator
    ✅ Spring Boot DevTools

```shell
curl https://start.spring.io/starter.zip -d dependencies=web,actuator -d javaVersion=17 -d type=maven-project -o cloud-native-app.zip
```

Unzip the project and navigate into it:

```shell
unzip cloud-native-app.zip -d cloud-native-app
cd cloud-native-app
```

3.2 Define a Simple REST API
Modify src/main/java/com/example/demo/HelloController.java:

```shell
@RestController
@RequestMapping("/api")
public class HelloController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Hello, Cloud-Native Java with Kubernetes & Istio!";
    }
}
```

3.3 Build & Run Locally

```shell
mvn clean package
java -jar target/*.jar
```

Test with:

```shell
curl http://localhost:8080/api/hello
```

4. Step 2: Containerize the Java Application

   4.1 Create a Dockerfile
   Create a Dockerfile in the project root:

```shell
FROM eclipse-temurin:23-jdk
LABEL authors="hendisantika"
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

4.2 Build & Push the Docker Image

```shell
docker build -t my-cloud-app:latest .
docker tag my-cloud-app:latest <your-dockerhub-username>/my-cloud-app:latest
docker push <your-dockerhub-username>/my-cloud-app:latest
```

5. Step 3: Deploy to Kubernetes
   5.1 Create Kubernetes Deployment & Service
   Create k8s-deployment.yaml:

```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cloud-app
  template:
    metadata:
      labels:
        app: cloud-app
    spec:
      containers:
      - name: cloud-app
        image: <your-dockerhub-username>/my-cloud-app:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-app-service
spec:
  selector:
    app: cloud-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

Apply it:

```shell
kubectl apply -f k8s-deployment.yaml
```

Check the service:

```shell
kubectl get svc cloud-app-service
```

6. Step 4: Install and Configure Istio

   6.1 Install Istio

```shell
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```   

6.2 Deploy Istio Gateway & VirtualService
Create istio-gateway.yaml:

```shell
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: cloud-app-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: cloud-app
spec:
  hosts:
  - "*"
  gateways:
  - cloud-app-gateway
  http:
  - match:
    - uri:
        prefix: /api
    route:
    - destination:
        host: cloud-app-service
        port:
          number: 80
```

Apply it:

```shell
kubectl apply -f istio-gateway.yaml
```

Get Istio Ingress Gateway IP:

```shell
kubectl get svc istio-ingressgateway -n istio-system
```

Test with:

```shell
curl http://<EXTERNAL-IP>/api/hello
```

7. Step 5: Monitoring & Security with Istio
   7.1 Enable Observability with Kiali & Grafana
   Install Kiali, Grafana, and Jaeger:

```
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
```

Access Kiali UI:

```shell
istioctl dashboard kiali
```

7.2 Secure Communication with Istio mTLS
Enable mTLS:

```shell

apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
name: default
spec:
mtls:
mode: STRICT
```

Apply it:

```shell
kubectl apply -f mtls.yaml
```

8. Conclusion

       ✅ You’ve successfully built a cloud-native Java application
       ✅ Deployed it in Kubernetes with Istio
       ✅ Secured and monitored your app using Istio Service Mesh

🎯 Next Steps:

Implement Canary Deployments with Istio
Enable Rate Limiting & Circuit Breakers
Add Distributed Tracing with Jaeger
