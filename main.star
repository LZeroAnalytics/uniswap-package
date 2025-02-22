def run(plan, args):
    plan.add_service(
        name="uniswap-ui",
        config=ServiceConfig(
            image="tiljordan/uniswap-ui:v1.0.0",
            ports={
                "api": PortSpec(number=3000, transport_protocol="TCP", wait=None),
            },
            env_vars = {
                "RPC_URL": args["RPC_URL"],
            },
        )
    )