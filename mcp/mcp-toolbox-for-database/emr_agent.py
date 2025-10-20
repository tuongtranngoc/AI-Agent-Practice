import asyncio

from langgraph.prebuilt import ToolNode
from toolbox_langchain import ToolboxClient
from langgraph.checkpoint.memory import MemorySaver
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.graph import StateGraph, MessagesState, START, END



prompt = """
  You're a helpful medical appointment assistant for an EMR (Electronic Medical Records) system. 
  You handle doctor searching, appointment booking, updates, and cancellations. 
  When the user searches for a doctor, mention their name, id, specialty, and availability. 
  Always mention doctor ids while performing any operations. This is very important for all operations. 
  For any bookings or cancellations, please provide the appropriate confirmation. 
  Be sure to update appointment date or time if mentioned by the user.
  Don't ask for confirmations from the user.
"""

queries = [
    "Find doctors specializing in Cardiology.",
    "Can you book an appointment with Dr. Smith for me?",
    "Oh wait, I need to cancel that appointment and book with Dr. Johnson instead.",
    "My appointment should be on April 15, 2024 at 10:00 AM.",
]

def create_agent_graph(model, tools, checkpointer):
    model_with_tools = model.bind_tools(tools)
    
    # Define the agent node that calls the model
    def call_model(state: MessagesState):
        messages = state["messages"]
        response = model_with_tools.invoke(messages)
        return {"messages": [response]}
    
    def should_continue(state: MessagesState):
        messages = state["messages"]
        last_message = messages[-1]
        if not last_message.tool_calls:
            return END
        else:
            return "tools"
    
    # Build the graph
    workflow = StateGraph(MessagesState)
    
    # Add nodes
    workflow.add_node("agent", call_model)
    workflow.add_node("tools", ToolNode(tools))
    
    # Add edges
    workflow.add_edge(START, "agent")
    workflow.add_conditional_edges("agent", should_continue, ["tools", END])
    workflow.add_edge("tools", "agent")
    
    # Compile with checkpointer
    return workflow.compile(checkpointer=checkpointer)

async def main():
    model = ChatGoogleGenerativeAI(model="gemini-2.0-flash-001")
    # Load the tools from the Toolbox server
    async with ToolboxClient("http://0.0.0.0:5000") as client:
        tools = await client.aload_toolset()

        # Create the agent using the newer graph pattern
        agent = create_agent_graph(model, tools, checkpointer=MemorySaver())

        config = {"configurable": {"thread_id": "thread-1"}}
        for query in queries:
            inputs = {"messages": [("user", prompt + query)]}
            response = agent.invoke(inputs, stream_mode="values", config=config)
            print(response["messages"][-1].content)

asyncio.run(main())
