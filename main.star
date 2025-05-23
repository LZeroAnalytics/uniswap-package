ethereum = import_module("github.com/LZeroAnalytics/ethereum-package/main.star")

def run(plan, args, rpc_url=None, backend_url=None):
    if not rpc_url:
        plan.print("Running the ethereum package")
        output = ethereum.run(plan, args)
        first_participant = output.all_participants[0]
        rpc_url = "http://{}:{}".format(
            first_participant.el_context.ip_addr,
            first_participant.el_context.rpc_port_num
        )

    plan.print(rpc_url)

    # Add Uniswap services
    backend = plan.add_service(
        name="uniswap-backend",
        config=ServiceConfig(
            image="tiljordan/uniswap-routing-api:v1.0.0",
            ports={
                "api": PortSpec(number=3000, transport_protocol="TCP"),
            },
            public_ports={
                "api": PortSpec(
                    number=8080,
                    transport_protocol="TCP",
                    application_protocol="http"
                )
            },
            env_vars = {
                "RPC_URL": rpc_url,
            },
        )
    )

    # Warm up the routing API
    plan.request(
        service_name = "uniswap-backend",
        recipe = GetHttpRequestRecipe(
            port_id = "api",
            endpoint = "/quote?tokenInAddress=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2&tokenInChainId=1&tokenOutAddress=0x1f9840a85d5af5bf1d1762f925bdaddc4201f984&tokenOutChainId=1&amount=100&type=exactIn",
        ),
        skip_code_check = True,
        description = "Warming up routing api"
    )

    if backend_url == None:
        backend_url = "http://127.0.0.1:8080"

    ui = plan.add_service(
        name="uniswap-ui",
        config=ServiceConfig(
            image="tiljordan/uniswap-ui:v1.0.8",
            ports={
                "api": PortSpec(number=3000, transport_protocol="TCP"),
            },
            env_vars = {
                "SERVER_URL": backend_url
            },
        )
    )

    uniswap_services = struct(
        backend = backend,
        ui = ui
    )

    return uniswap_services