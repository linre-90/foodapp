export interface ServerToClientEvents {
    onOrderPushed: () => void;
    orderStateUpdate: (arg: OrderStateUpdate) => void;
    onOrderStatusChanged: (arg: OrderStateUpdate) => void;
}

export interface ClientToServerEvents {
    hello: () => void;
}

export interface InterServerEvents {
    ping: () => void;
}

export interface SocketData {
    name: string;
    age: number;
}

export enum OrderState{
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

export type OrderStateUpdate = {
    id: string
    state: OrderState
}