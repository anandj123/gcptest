package org.test.webapp;

import com.google.auth.oauth2.AccessToken;
import com.google.auth.oauth2.GoogleCredentials;
import io.opencensus.common.Scope;
import io.opencensus.exporter.trace.stackdriver.StackdriverTraceConfiguration;
import io.opencensus.exporter.trace.stackdriver.StackdriverTraceExporter;
import io.opencensus.trace.Tracer;
import io.opencensus.trace.Tracing;
import io.opencensus.trace.propagation.TextFormat;
import io.opencensus.trace.samplers.Samplers;
// Import required java libraries
import java.io.*;
//import java.io.IOException;
//import java.io.IOException;
//import java.net.URI;
/*
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
*/
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;
import javax.servlet.*;
import javax.servlet.http.*;
// import org.apache.http.Header;
// import org.apache.http.HttpEntity;
// import org.apache.http.client.methods.CloseableHttpResponse;
// import org.apache.http.client.methods.HttpGet;
// import org.apache.http.impl.client.CloseableHttpClient;
// import org.apache.http.impl.client.HttpClients;
// import org.apache.http.util.EntityUtils;
import org.joda.time.DateTime;

// Extend HttpServlet class
public class HelloServlet extends HttpServlet {
  private String message;
  // [START trace_setup_java_custom_span]
  private static final Tracer tracer = Tracing.getTracer();

  private static void doInitialWork() {
    // ...
    tracer.getCurrentSpan().addAnnotation("Doing initial work");
    // ...
  }

  public void init() throws ServletException {
    try {
      HelloServlet.createAndRegisterGoogleCloudPlatform("anand-bq-test-2");
    } catch (Exception e) {
      e.printStackTrace();
    }

    // Do required initialization
    try (
      Scope ss = tracer
        .spanBuilder("Initial Load Span init()")
        .setSampler(Samplers.alwaysSample())
        .startScopedSpan()
    ) {
      doInitialWork();
      message =
        "Hello World from Anand Servlet with Stackdriver Opencensus tracing enabled.";
    }
  }

  // [START trace_setup_java_create_and_register]
  public static void createAndRegister() throws IOException {
    StackdriverTraceExporter.createAndRegister(
      StackdriverTraceConfiguration.builder().build()
    );
  }

  // [END trace_setup_java_create_and_register]

  // [START trace_setup_java_create_and_register_with_token]
  public static void createAndRegisterWithToken(String accessToken)
    throws IOException {
    Date expirationTime = DateTime.now().plusSeconds(60).toDate();

    GoogleCredentials credentials = GoogleCredentials.create(
      new AccessToken(accessToken, expirationTime)
    );
    StackdriverTraceExporter.createAndRegister(
      StackdriverTraceConfiguration
        .builder()
        .setProjectId("anand-bq-test-2")
        .setCredentials(credentials)
        .build()
    );
  }

  // [END trace_setup_java_create_and_register_with_token]

  // [START trace_setup_java_register_exporter]
  public static void createAndRegisterGoogleCloudPlatform(String projectId)
    throws IOException {
    StackdriverTraceExporter.createAndRegister(
      StackdriverTraceConfiguration.builder().setProjectId(projectId).build()
    );
  }

  // [END trace_setup_java_register_exporter]

  private static final TextFormat textFormat = Tracing
    .getPropagationComponent()
    .getB3Format();
  private static final TextFormat.Setter setter = new TextFormat.Setter<HttpURLConnection>() {

    public void put(HttpURLConnection carrier, String key, String value) {
      carrier.setRequestProperty(key, value);
    }
  };

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    try (
      Scope ss = tracer
        .spanBuilder("Parent_Span_doGet")
        .setSampler(Samplers.alwaysSample())
        .startScopedSpan()
    ) {
      tracer.getCurrentSpan().addAnnotation("Start parent work");

      response.setContentType("text/html");
      PrintWriter out = response.getWriter();
      out.println(message + "<br>");

      out.println("starting child call <br>");

      HttpURLConnection conn = (HttpURLConnection) new URL(
        "http://localhost:8080/testchild/hello"
      )
      .openConnection();

      // Inject current span context to header for remote distributed tracing
      textFormat.inject(tracer.getCurrentSpan().getContext(), conn, setter);

      StringBuilder result = new StringBuilder();
      BufferedReader rd = new BufferedReader(
        new InputStreamReader(conn.getInputStream())
      );
      String line;
      while ((line = rd.readLine()) != null) {
        result.append(line);
      }
      rd.close();
      out.println(result.toString());
      tracer.getCurrentSpan().addAnnotation("Finished parent work");
    }
  }

  public void destroy() {
    // do nothing.
  }
}
