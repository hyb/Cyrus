
import java.util.*;
import netmash.forest.WebObject;

/** .
  */
public class HRLeavePeriods extends WebObject {

    public HRLeavePeriods(){}

    public HRLeavePeriods(String leaveRequestuid){
        super("{ \"is\": [ \"hr\", \"leave-period\" ],\n"+
              "  \"leaveRequest\": \""+leaveRequestuid+"\",\n"+
              "  \"ask\": 81.9,\n"+
              "  \"status\": \"waiting\"\n"+
              "}");
    }

    public void evaluate(){
        if(contentListContains("is", "leave-record")){
            makeLeavePeriod();
        }
        else
        if(contentListContains("is", "leave-period")){
            mirrorLeaveRequest();
            configLeavePeriod();
            checkNotAsRequested();
            acceptLeaveResponse();
        }
    }

    private void makeLeavePeriod(){
        for(String leaveRequestuid: alerted()){ logrule();
            content("leaveRequest", leaveRequestuid);
            String leaveRequestLeavePeriod = content("leaveRequest:leavePeriod");
            if(leaveRequestLeavePeriod==null){
                contentListAdd("leavePeriods", spawn(new HRLeavePeriods(leaveRequestuid)));
            }
        }
    }

    private void configLeavePeriod(){
        if(!contentSet("buylim")){
            contentDouble("buylim", contentDouble("leaveRequest:buylim"));
            contentDouble("price",  contentDouble("leaveRequest:price"));
            notifying(content("leaveRequest"));
            setUpPseudoMarketMoverInterfaceCallback();
        }
    }

    private void mirrorLeaveRequest(){
        if(contentIs("status", "waiting") && 
           contentSet("buylim") && 
           contentSet("leaveRequest:buylim")){ logrule();

            contentDouble("buylim", contentDouble("leaveRequest:buylim"));
            contentDouble("price",  contentDouble("leaveRequest:price"));
        }
    }

    private void checkNotAsRequested(){
        if(contentIs("status", "filled") || contentListContains("status", "filled")){ logrule();
            if( contentDouble("buylim") !=     contentDouble("leaveRequest:buylim")  ||
                contentDouble("price") !=     contentDouble("leaveRequest:price")    ){

                contentList("status", list("filled", "not-as-requested"));
            }
            else{
                content("status", "filled");
            }
        }
    }

    private void acceptLeaveResponse(){
        if(contentIs("status","filled") || contentListContains("status", "filled")){ logrule();
            if(contentDouble("leaveRequest:leaveResponse:amount") == contentDouble("ask") * contentDouble("price")){
                content("status", "paid");
                content("leaveResponse", content("leaveRequest:leaveResponse"));
            }
        }
    }

    // ----------------------------------------------------

    private void marketMoved(final double price){
        new Evaluator(this){
            public void evaluate(){ logrule();
                contentDouble("ask", price);
                if(price < contentDouble("buylim")){
                    content("status", "filled");
                }
                refreshObserves();
            }
        };
    }

    // ----------------------------------------------------

    static private double[] prices = { 81.8, 81.6 };
    private void setUpPseudoMarketMoverInterfaceCallback(){
        new Thread(){ public void run(){
            for(int i=0; i<prices.length; i++){
                try{ Thread.sleep(500); }catch(Exception e){}
                marketMoved(prices[i]);
            }
        } }.start();
    }

    // ----------------------------------------------------
}

