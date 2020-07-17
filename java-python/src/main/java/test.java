package src.main.java;
import java.io.*;
import javax.script.*;
import java.util.*;

public class test{
    public static void main(String[] args){
        try{
            givenPythonScriptEngineIsAvailable_whenScriptInvoked_thenOutputDisplayed();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public static void givenPythonScriptEngineIsAvailable_whenScriptInvoked_thenOutputDisplayed() throws Exception {
        
        StringWriter writer = new StringWriter();
        ScriptContext context = new SimpleScriptContext();
        context.setWriter(writer);
     
        ScriptEngineManager manager = new ScriptEngineManager();
        List<ScriptEngineFactory> factories = manager.getEngineFactories();
        for (ScriptEngineFactory factory : factories) {
            System.out.println(factory.getEngineName());
            System.out.println(factory.getEngineVersion());
            System.out.println(factory.getLanguageName());
            System.out.println(factory.getLanguageVersion());
            System.out.println(factory.getExtensions());
            System.out.println(factory.getMimeTypes());
            System.out.println(factory.getNames());
            System.out.println("----------------------");
        }
        ScriptEngine engine = manager.getEngineByName("python");
        System.out.println(engine);
        engine.eval(new FileReader("hello.py"), context);
        System.out.println(writer.toString().trim());
    }
}
