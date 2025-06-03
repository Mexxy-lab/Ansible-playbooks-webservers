import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

export class RestApiStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const handler = new lambda.Function(this, 'ApiHandler', {
      runtime: lambda.Runtime.NODEJS_18_X,
      code: lambda.Code.fromAsset('lambda'),
      handler: 'index.handler',
    });

    const api = new apigateway.RestApi(this, 'MyApi', {
      restApiName: 'MyService',
    });

    const users = api.root.addResource('users');
    users.addMethod('GET', new apigateway.LambdaIntegration(handler));
  }
}
