import { ReactElement, useEffect, useState } from 'react'
import {useOrders} from "./hooks";
import {OrderData, OrderState} from "./hooks"
import { io } from 'socket.io-client';

type OrderProps = {
    order: OrderData | undefined;
    id: number;
    orderStateUpdate: (arg0: number, arg1: OrderState) => Promise<boolean>;
    orderFullyProcessed: () => void;
}

const socket = io("http://localhost:8080");

function OrderComponent({order, id, orderStateUpdate, orderFullyProcessed}: OrderProps){
    // Return with empty component if order is undefined
    if(order === undefined){ return <></> }

    // Order progression state
    const [orderState, setOrderState] = useState<OrderState>(order.state);
    // Button color styles
    const style = ["red", "orange","yellow", "green"]
    
    // Notify backend about order progression changes.
    const setNextOrderState = async () =>  {
        switch (orderState) {
            case OrderState.WAITING:
                if(await orderStateUpdate(id, OrderState.PREPARING)){
                    setOrderState(OrderState.PREPARING);
                }
                break;
            case OrderState.PREPARING:
                if(await orderStateUpdate(id, OrderState.READY)){
                    setOrderState(OrderState.READY);
                }
                break;
            case OrderState.READY:
                if(await orderStateUpdate(id, OrderState.DELIVERED)){
                    setOrderState(OrderState.DELIVERED);
                    // We don't do anything with completed orders, request updated order list from backend.
                    orderFullyProcessed();
                }
                break;
            default:
                break;
        }
    }

    // Render order component.
    return(
        <div style={{border: "1px solid black", margin: "20px", padding: "5px" }}>
            <h3>Order id: {id}</h3>
            {
                order.items.map(i => {return (
                    <div key={i.name?.concat(id.toString())}>
                        <p >name: {i.name}</p>
                        <p style={{marginLeft: "20px"}}>drink: {i.drink}</p>
                    </div>
                )})
            }
            <button 
                style={{color: style[orderState], backgroundColor: "lightgray", padding: "5px"}} 
                onClick={setNextOrderState}>
                    <strong>{OrderState[orderState]}</strong> 
            </button>
        </div>
    )
}


function App() {
    const [orders, refresh, updateOrderState] = useOrders();
    const [socketConnection, setSocketConnection] = useState<boolean>(false);
    const orderComponents: ReactElement[] = [];


    useEffect(() => {
        // Socket stuff is handled in here.
        function onConnect(){ setSocketConnection(true); }
        function onDisconnect(){ setSocketConnection(false); }
        function onOrderPushed(){ refresh();}

        socket.on("connect", onConnect);
        socket.on("onOrderPushed", onOrderPushed);
        socket.on("onDisconnect", onDisconnect);
        
        return () => {
            socket.off('connect', onConnect);
            socket.off("onOrderPushed", onOrderPushed);
            socket.off("onDisconnect", onDisconnect);
          };
    }, []);

    // Cannot reach server
    if(orders === null || !socketConnection){
        return(
        <>
            <h1>Best burger</h1>
            <p>Error, cannot contacting server. Please refresh!</p>
        </>
        )
    }

    // Convert order map to orderComponents.
    orders.forEach((_, k) => {
        orderComponents.push(<OrderComponent key={k} order={orders.get(k)} id={k} orderStateUpdate={updateOrderState} orderFullyProcessed={refresh}/>);
    });

    // Render order components.
    return (
        <>
            <h1>Best burger</h1>
            { orderComponents.length > 0 ? orderComponents.map(e => e): <p>No pending orders, <b>do prep work or get fired...</b></p>}
        </>
    )
}

export default App
