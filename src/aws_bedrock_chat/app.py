import logging
import os
from typing import Dict, Any

import boto3
import chainlit as cl
from dotenv import load_dotenv
from botocore.client import BaseClient

# Constants
SUCCESS_STATUS = "SUCCESS"
FLOW_INPUT_NODE = "FlowInputNode"
NODE_OUTPUT_NAME = "document"

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def initialize_aws_clients() -> tuple[BaseClient, BaseClient]:
    """
    Initialize AWS Bedrock clients.
    
    Returns:
        tuple: Bedrock runtime and agent runtime clients
    """
    load_dotenv()
    return (
        boto3.client('bedrock-runtime'),
        boto3.client('bedrock-agent-runtime')
    )

async def process_flow_response(response: Dict[str, Any]) -> str:
    """
    Process the streaming response from AWS Bedrock Flow.
    
    Args:
        response: Raw response from AWS Bedrock Flow
        
    Returns:
        str: Processed response text
    """
    result = {}
    for event in response.get("responseStream", []):
        result.update(event)
        
    if result.get('flowCompletionEvent', {}).get('completionReason') == SUCCESS_STATUS:
        return result.get('flowOutputEvent', {}).get('content', {}).get(NODE_OUTPUT_NAME, '')
    return ""

bedrock_runtime, bedrock_agent_runtime = initialize_aws_clients()

@cl.on_chat_start
async def start() -> None:
    """Initialize chat session with welcome message."""
    await cl.Message(content="Welcome! How can I assist you today?").send()

@cl.on_message
async def on_message(message: cl.Message) -> None:
    """
    Process incoming user messages using AWS Bedrock.
    
    Args:
        message: User message object from Chainlit
    """
    try:
        logger.info("Received message: %s", message.content)

        flow_response = bedrock_agent_runtime.invoke_flow(
            flowIdentifier=os.getenv('FLOW_ID'),
            flowAliasIdentifier=os.getenv('FLOW_ALIAS_ID'),
            inputs=[{
                "content": {"document": message.content},
                "nodeName": FLOW_INPUT_NODE,
                "nodeOutputName": NODE_OUTPUT_NAME
            }]
        )
        
        response_text = await process_flow_response(flow_response)
        
        if response_text:
            await cl.Message(content=response_text).send()
        else:
            await cl.Message(content="No response received from the model.").send()

    except Exception as e:
        logger.error("Error processing message: %s", str(e))
        await cl.Message(
            content="I apologize, but I couldn't process your request at the moment."
        ).send() 