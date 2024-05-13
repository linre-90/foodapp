import { useState, useEffect } from "react"

export enum OrderState {
    WAITING,
    PREPARING,
    READY,
    DELIVERED
}

export type OrderData = {
    items: Order[];
    state: OrderState
}

export type Order = {
    name: string | undefined;
    drink: string | undefined;
}

const testingToken: string = "askjdsoiasdlkj987123s";

/**
 * Custom hook to interact with backend server.
 * @returns 
 */
export function useOrders() {
    // create state, same structure as in backend server.
    const [orders, setOrders] = useState<Map<number, OrderData> | null>(new Map<number, OrderData>);
    
    // Request fresh listing of orders from the server.
    const refresh = async () => {
        try {
            const res = await fetch("http://localhost:8080/api/order", {
            method: "GET",
            headers: { "token": testingToken }
        });

        const obj = await res.json();
        if (obj !== null || obj !== undefined && res.status === 200) {
            //@ts-ignore, "Object.entries(obj)" <- causes too much headache with typescript...
            setOrders(new Map<number, OrderData>(Object.entries(obj)));
        }
        } catch (error) {
            setOrders(null);
        }
        
    }

    /**
     * Update order state on server.
     * @param key 
     * @param state 
     * @returns 
     */
    const updateOrderState = async (key: number, state: OrderState): Promise<boolean> => {
        const res = await fetch("http://localhost:8080/api/order/update", {
            method: "POST",
            headers: { "token": testingToken, "Content-Type": "application/json" },
            body: JSON.stringify({id: key, state: state})
        });

        if(res.status === 200){
            return true;
        }
        return false;
    }

    useEffect(() => {
        // Initial data fetch
        refresh();
    }, []);

    return [orders, refresh, updateOrderState] as const
}