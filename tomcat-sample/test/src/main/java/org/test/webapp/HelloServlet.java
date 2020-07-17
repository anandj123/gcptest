package org.test.webapp;

// Import required java libraries
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.google.auth.oauth2.AccessToken;
import com.google.auth.oauth2.GoogleCredentials;
import io.opencensus.common.Scope;
import io.opencensus.exporter.trace.stackdriver.StackdriverTraceConfiguration;
import io.opencensus.exporter.trace.stackdriver.StackdriverTraceExporter;
import io.opencensus.trace.Tracer;
import io.opencensus.trace.Tracing;
import io.opencensus.trace.samplers.Samplers;
import java.io.IOException;
import java.util.Date;
import org.joda.time.DateTime;

// Extend HttpServlet class
public class HelloServlet extends HttpServlet {

   // [START trace_setup_java_custom_span]
   private static final Tracer tracer = Tracing.getTracer();

   private static void doInitialWork() {
      // ...
      tracer.getCurrentSpan().addAnnotation("Doing initial work");
      // ...
   }

   private static void doFinalWork() {
      // ...
      tracer.getCurrentSpan().addAnnotation("Hello world!");
      // ...
   }

   private String message;

   public void init() throws ServletException {
      try {
         HelloServlet.createAndRegisterGoogleCloudPlatform("anand-bq-test-2");
      } catch (Exception e) {
         e.printStackTrace();
      }

      // Do required initialization
      try (Scope ss = tracer.spanBuilder("MyChildWorkSpan").setSampler(Samplers.alwaysSample()).startScopedSpan()) {
         doInitialWork();
         message = "Hello World from Servlet with Stackdriver Opencensus tracing enabled.";

      }

   }

   // [START trace_setup_java_create_and_register]
   public static void createAndRegister() throws IOException {
      StackdriverTraceExporter.createAndRegister(StackdriverTraceConfiguration.builder().build());
   }
   // [END trace_setup_java_create_and_register]

   // [START trace_setup_java_create_and_register_with_token]
   public static void createAndRegisterWithToken(String accessToken) throws IOException {
      Date expirationTime = DateTime.now().plusSeconds(60).toDate();

      GoogleCredentials credentials = GoogleCredentials.create(new AccessToken(accessToken, expirationTime));
      StackdriverTraceExporter.createAndRegister(StackdriverTraceConfiguration.builder().setProjectId("anand-bq-test-2")
            .setCredentials(credentials).build());
   }
   // [END trace_setup_java_create_and_register_with_token]

   // [START trace_setup_java_register_exporter]
   public static void createAndRegisterGoogleCloudPlatform(String projectId) throws IOException {
      StackdriverTraceExporter
            .createAndRegister(StackdriverTraceConfiguration.builder().setProjectId(projectId).build());
   }
   // [END trace_setup_java_register_exporter]

   public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
      try (Scope ss = tracer.spanBuilder("Servlet Span doGet").setSampler(Samplers.alwaysSample()).startScopedSpan()) {
         // Set response content type
         response.setContentType("text/html");
         // Actual logic goes here.
         PrintWriter out = response.getWriter();
         out.println("<h1>" + message + "</h1>");
         tracer.getCurrentSpan().addAnnotation("Finished initial work");
      }
   }

   public void destroy() {
      // do nothing.
   }
}