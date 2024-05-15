import express, {Express, Request, Response, NextFunction} from "express";
import { Server } from "socket.io";
import http from "http";
import { ServerToClientEvents, Order, OrderData, OrderState, OrderStateUpdate} from "./types";

// Initialize express app and middleware
const app: Express  = express();
app.use(express.json());

// Middleware to add cors headers
app.use((req: Request, res: Response, next: NextFunction) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, content-type, token');
    res.setHeader('Access-Control-Allow-Credentials', "true");
    next();
});

// Initialize http server and socket io
const server = http.createServer(app);
const io = new Server<ServerToClientEvents>(server, {cors: {origin:"*"}});


// Track order id
let orderId = -1;

// Orders are stored in map
const orders = new Map<number, OrderData>();

// This is sample key for restaurant app, only for testing
const sampleKey = "askjdsoiasdlkj987123s";


/**
 * Simple and dirty way to validate orderData
 * Throws exception if orderData and orders is not formed correctly.
 * @param order 
 */
function checkOrder(order: OrderData){
    order.items.forEach(o => {
        if(o.drink === undefined || o.name === undefined){
            throw Error();
        }
    });
}

// Accept orders from application
app.post("/api/order", (req: Request, res: Response) => {
    // Wrap it to catch errors when parsing order
    try {
        // Parse and check order
        const orderData: OrderData = req.body as OrderData;
        orderData.state = OrderState.WAITING;
        checkOrder(orderData);
        // Book order and emit order push event.
        orderId++;
        orders.set(orderId, orderData);
        io.emit("onOrderPushed");
        res.status(200).send(orderId.toString());
    } catch (error) {
        // Something went wrong when handling order, most likely invalid orderData format.
        res.status(400).send("Bad request.");
    }
});

/**
 * Handles sending out collected orders to restaurant web app.
 */
app.get("/api/order", (req: Request, res: Response) => {
    // sample auth
    const token: string | string[] | undefined = req.headers["token"];
    if(typeof token === typeof ["",""] || token === undefined || token !== sampleKey){
        res.status(401).send("Unauthorized.");
    }else{
        // Send orders, filter out READY state orders to temp map
        const filteredOrders = new Map<number, OrderData>();
        orders.forEach((_, key) => {
            if(orders.get(key) !== undefined){
                // so enum does not work in next if statement...
                if(orders.get(key)!.state !== 3){
                    filteredOrders.set(key, orders.get(key)!);
                }
            }
        });
        res.status(200).json(Object.fromEntries(filteredOrders));
    }
});

/**
 * Handles order state updating.
 */
app.post("/api/order/update", (req: Request, res: Response) => {
    // sample auth
    const token: string | string[] | undefined = req.headers["token"];
    if(typeof token === typeof ["",""] || token === undefined || token !== sampleKey){
        res.status(401).send("Unauthorized.");
    }else{
        // update order state
        const stateUpdate: OrderStateUpdate = req.body as OrderStateUpdate;
        const mapItemRef = orders.get(Number.parseInt(stateUpdate.id));
        if(mapItemRef){
            mapItemRef.state = stateUpdate.state as OrderState;
            io.emit("onOrderStatusChanged", stateUpdate);
            // Here we could check if order state is DELIVERED and archive it to database and remove from map... 
            res.status(200).send();
        }else{
            res.status(404).send();
        }
    }
});

io.on("connection", (socket) => { console.log("Client connected.")} );

server.listen(8080, () => { console.log("Server running at http://localhost:8080")});

