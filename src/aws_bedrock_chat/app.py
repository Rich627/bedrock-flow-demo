"""
Main application module for AWS Bedrock Chat
This module handles the Chainlit chat interface and message processing
"""

import os
import chainlit as cl
from dotenv import load_dotenv
from .services.bedrock_service import BedrockService

# Load environment variables
load_dotenv()

# Initialize Bedrock service
bedrock_service = BedrockService(
    region=os.getenv('AWS_REGION'),
    flow_alias_arn=os.getenv('FLOW_ALIAS_ARN')
)

@cl.on_chat_start
async def start():
    """Initialize chat session"""
    await cl.Message(
        content="Welcome! How can I assist you today?"
    ).send()

@cl.on_message
async def on_message(message: cl.Message):
    """
    Process incoming user messages using AWS Bedrock
    
    Args:
        message: User message object from Chainlit
    """
    try:
        # Get response from Bedrock service
        response = bedrock_service.invoke_flow(message.content)
        
        if response:
            await cl.Message(content=response).send()
        else:
            await cl.Message(
                content="I apologize, but I couldn't process your request at the moment."
            ).send()

    except Exception as e:
        await cl.Message(
            content=f"An error occurred while processing your request: {str(e)}"
        ).send() 