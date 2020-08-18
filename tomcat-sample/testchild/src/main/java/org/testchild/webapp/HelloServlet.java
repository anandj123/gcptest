package org.testchild.webapp;

import com.google.auth.oauth2.AccessToken;
import com.google.auth.oauth2.GoogleCredentials;
import io.opencensus.common.Scope;
import io.opencensus.exporter.trace.stackdriver.StackdriverTraceConfiguration;
import io.opencensus.exporter.trace.stackdriver.StackdriverTraceExporter;
import io.opencensus.trace.AttributeValue;
import io.opencensus.trace.Link;
import io.opencensus.trace.Span;
import io.opencensus.trace.SpanBuilder;
import io.opencensus.trace.SpanContext;
import io.opencensus.trace.Tracer;
import io.opencensus.trace.Tracing;
import io.opencensus.trace.propagation.SpanContextParseException;
import io.opencensus.trace.propagation.TextFormat;
import io.opencensus.trace.samplers.Samplers;
// Import required java libraries
import java.io.*;
import java.io.IOException;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.http.*;
import org.joda.time.DateTime;

// Extend HttpServlet class
public class HelloServlet extends HttpServlet {
  // [START trace_setup_java_custom_span]
  private static final Tracer tracer = Tracing.getTracer();

  private static void doInitialWork() {
    tracer.getCurrentSpan().addAnnotation("Doing initial work");
  }

  private String message;

  public void init() throws ServletException {
    try {
      HelloServlet.createAndRegisterGoogleCloudPlatform("anand-bq-test-2");
    } catch (Exception e) {
      e.printStackTrace();
    }

    // Do required initialization
    try (
      Scope ss = tracer
        .spanBuilder("Initial load Child Microservice init()")
        .setSampler(Samplers.alwaysSample())
        .startScopedSpan()
    ) {
      doInitialWork();
      message =
        "Test child microservice with Stackdriver Opencensus tracing enabled.";
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
  private static final TextFormat.Getter<HttpServletRequest> getter = new TextFormat.Getter<HttpServletRequest>() {

    @Override
    public String get(HttpServletRequest httpRequest, String s) {
      return httpRequest.getHeader(s);
    }
  };

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    SpanContext spanContext;
    SpanBuilder spanBuilder;

    String spanName = request.getMethod() + " " + request.getRequestURI();

    try {
      spanContext = textFormat.extract(request, getter);
      spanBuilder =
        tracer.spanBuilderWithRemoteParent("Child_Span_doGet", spanContext);
    } catch (SpanContextParseException e) {
      spanBuilder = tracer.spanBuilder(spanName);
      System.out.println("Parent Span is not present");
    }

    Span span = spanBuilder
      .setRecordEvents(true)
      .setSampler(Samplers.alwaysSample())
      .startSpan();

    PrintWriter out = response.getWriter();

    span.addAnnotation("Starting child work");

    response.setContentType("text/html");
    out.println(message + "<br>");

    @SuppressWarnings("unchecked")
    Enumeration<String> headerNames = request.getHeaderNames();
    if (headerNames != null) {
      while (headerNames.hasMoreElements()) {
        String key = headerNames.nextElement();
        String value = request.getHeader(key);
        System.out.println(
          "Header: Key [" + key + "] value [" + value + "] <br>"
        );
        out.println("Header: Key [" + key + "] value [" + value + "] <br>");
      }
    }

    span.addAnnotation("Finished child work");

    span.end();
  }
}
