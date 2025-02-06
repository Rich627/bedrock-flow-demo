import json
import boto3
from typing import Optional

class BedrockService:
    """Service class for AWS Bedrock interactions"""
    
    def __init__(self, region: str, flow_alias_arn: str):
        """
        Initialize Bedrock service
        
        Args:
            region: AWS region
            flow_alias_arn: Bedrock Flow Alias ARN
        """
        self.region = region
        self.flow_alias_arn = flow_alias_arn
        self.client = boto3.client("bedrock-runtime", region_name=region)
    
    def invoke_flow(self, input_text: str) -> Optional[str]:
        """
        Invoke Bedrock Flow with input text
        
        Args:
            input_text: User input text
            
        Returns:
            Response text from Bedrock Flow
        """
        try:
            response = self.client.invoke_model(
                modelId="bedrock-flow",
                contentType="application/json",
                accept="application/json",
                body=json.dumps({
                    "flowArn": self.flow_alias_arn,
                    "inputText": input_text
                })
            )
            
            response_body = json.loads(response.get('body').read())
            return response_body.get("outputText")
            
        except Exception as e:
            print(f"Error invoking Bedrock Flow: {str(e)}")
            return None 