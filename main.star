def run(plan, rpc_url, backend_url):
    plan.add_service(
        name="uniswap-backend",
        config=ServiceConfig(
            image="tiljordan/uniswap-routing-api:v1.0.0",
            ports={
                "api": PortSpec(number=3000, transport_protocol="TCP"),
            },
            env_vars = {
                "RPC_URL": rpc_url,
            },
        )
    )

    plan.request(
        service_name = "uniswap-backend",
        recipe = GetHttpRequestRecipe(
            port_id = "api",
            endpoint = "/quote?tokenInAddress=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2&tokenInChainId=1&tokenOutAddress=0x1f9840a85d5af5bf1d1762f925bdaddc4201f984&tokenOutChainId=1&amount=100&type=exactIn",
        ),
        skip_code_check = True,
        description = "Warming up routing api"
    )

    plan.add_service(
        name="uniswap-ui",
        config=ServiceConfig(
            image="tiljordan/uniswap-ui:v1.0.11",
            ports={
                "api": PortSpec(number=3000, transport_protocol="TCP"),
            },
            env_vars = {
                "SERVER_URL": backend_url
            },
        )
    )