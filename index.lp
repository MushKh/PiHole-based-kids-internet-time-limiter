<? --[[
*  Pi-hole: A black hole for Internet advertisements
*  (c) 2017 Pi-hole, LLC (https://pi-hole.net)
*  Network-wide ad blocking via your own hardware.
*
*  This file is copyright under the latest version of the EUPL.
*  Please see LICENSE file for your rights under this license.
--]]

indexpage = true
mg.include('scripts/lua/header_authenticated.lp','r')

local request = mg.request_info
local allowed_hours = nil

-- Absolute path is safest!
local file_path = "/var/www/html/admin/myserver/Parameters.txt"

local content = "No data"

local file = io.open(file_path, "r")
if file then
    content = file:read("*a")
    file:close()
else
    content = "Cannot open file!"
end


if request.query_string then
    allowed_hours = request.query_string:match("get_minutes=([^&]+)")
    if allowed_hours then
        allowed_hours = allowed_hours:gsub("%+", " ")
        allowed_hours = allowed_hours:gsub("%%(%x%x)", function(h)
            return string.char(tonumber(h,16))
        end)

        -- write to file here if needed
    end
end


-- ======= Get GET parameter ?message= ======= mg.write(Mins_text) 
local Mins_text = nil
local request = mg.request_info  -- userdata, do NOT call it

if request.query_string then
	local message = request.query_string:match("allowed_hours=([^&]+)")
    if message then
        -- URL decode (+ → space, %xx → char)
        message = message:gsub("+", " ")
        message = message:gsub("%%(%x%x)", function(h)
            return string.char(tonumber(h,16))
        end)
        Mins_text = message
    end
end

?>

<!-- Small boxes (Stat box) -->
<div class="row">
    <div class="col-lg-3 col-sm-6">
        <!-- small box -->
        <div class="small-box bg-aqua no-user-select" id="total_queries" title="only A + AAAA queries">
            <div class="inner">
                <p>Allowed time</p>
                
            </div>
			<form method="GET" action="/admin/myserver/WritePar.lp">			
					<table>
						<tr>
							<td>Allowed time (min):</td>
							<td><input type="text" name="get_minutes" value=""></input></td>
							<td><button onclick=''>Save</button></td>
						</tr>
					</table>							
			</form>
						
			<div class="small-box-footer">
                <span >
				<?lua 
				if content then
					mg.write("Saved Minutes: ") 
					mg.write(content)
				end
				?>
				</span>
            </div>
        </div>
    </div>
    <!-- ./col -->
    <div class="col-lg-3 col-sm-6">
        <!-- small box -->
        <div class="small-box bg-red no-user-select">
            <div class="inner">
                <p>Times Logs </p>
                <h3 >  
					<?lua
						local directory = "/admin/myserver"

						-- Format date like PHP: date("d, m, Y")
						local date_string = os.date("%d, %m, %Y")

						local FileNameBase = "Limiter_log" .. date_string .. ".html"
						local FileNameFull = directory .. "/" .. FileNameBase

						mg.write('<a href="' .. FileNameFull .. '" title=""> Today times </a><br>')
				?>
				</h3>
            </div>
            <div class="icon">
               
            </div>

        </div>
    </div>
    <div class="col-lg-3 col-sm-6">
        <!-- small box -->
        <div class="small-box bg-aqua no-user-select" id="total_queries" title="Total number of queries">
            <div class="inner">
                <p>Total Queries</p>
                <h3 class="statistic"><span id="dns_queries">---</span></h3>
            </div>
            <div class="icon">
                <i class="fas fa-globe-americas"></i>
            </div>
            <a href="network" class="small-box-footer" id="total_clients">
                <span id="active_clients">-</span> active clients <i class="fa fa-arrow-circle-right"></i>
            </a>
        </div>
    </div>
    <!-- ./col -->
    <div class="col-lg-3 col-sm-6">
        <!-- small box -->
        <div class="small-box bg-red no-user-select">
            <div class="inner">
                <p>Queries Blocked</p>
                <h3 class="statistic"><span id="blocked_queries">---</span></h3>
            </div>
            <div class="icon">
                <i class="fas fa-hand-paper"></i>
            </div>
            <a href="queries?upstream=blocklist" class="small-box-footer">
                List blocked queries <i class="fa fa-arrow-circle-right"></i>
            </a>
        </div>
    </div>
    <!-- ./col -->
    <div class="col-lg-3 col-sm-6">
        <!-- small box -->
        <div class="small-box bg-yellow no-user-select">
            <div class="inner">
                <p>Percentage Blocked</p>
                <h3 class="statistic"><span id="percent_blocked">---</span></h3>
            </div>
            <div class="icon">
                <i class="fas fa-chart-pie"></i>
            </div>
            <a href="queries" class="small-box-footer">
                List all queries <i class="fa fa-arrow-circle-right"></i>
            </a>
        </div>
    </div>
    <!-- ./col -->
    <div class="col-lg-3 col-sm-6">
        <!-- small box -->
        <div class="small-box bg-green no-user-select">
            <div class="inner">
                <p>Domains on Lists</p>
                <h3 class="statistic"><span id="gravity_size">---</span></h3>
            </div>
            <div class="icon">
                <i class="fas fa-list-alt"></i>
            </div>
            <a href="groups-lists" class="small-box-footer">
                Manage lists <i class="fa fa-arrow-circle-right"></i>
            </a>
        </div>
    </div>
    <!-- ./col -->
</div>

<div class="row">
    <div class="col-md-12">
        <div class="box" id="queries-over-time">
            <div class="box-header with-border">
                <h3 class="box-title">Total queries</h3>
                <button class="btn btn-xs btn-default pull-right zoom-reset" data-sel="reset-history"><i class="fas fa-undo"></i>&nbsp;Reset zoom</button>
                <span class="pull-right zoom-info" data-toggle="tooltip" title="You can zoom this graph by either holding down the [Ctrl] key and using your mouse wheel or by using the &quot;pinch&quot; multi-touch gesture. You can furthermore click and drag to pan the graph."><i class="fa fa-info-circle"></i></span>
            </div>
            <div class="box-body">
                <div class="chart" style="width: 100%; height: 180px">
                    <canvas id="queryOverTimeChart"></canvas>
                </div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="box" id="clients">
            <div class="box-header with-border">
                <h3 class="box-title">Client activity</h3>
                <button class="btn btn-xs btn-default pull-right zoom-reset" data-sel="reset-clients"><i class="fas fa-undo"></i>&nbsp;Reset zoom</button>
                <span class="pull-right zoom-info" data-toggle="tooltip" title="You can zoom this graph by either holding down the [Ctrl] key and using your mouse wheel or by using the &quot;pinch&quot; multi-touch gesture. You can furthermore click and drag to pan the graph."><i class="fa fa-info-circle"></i></span>
            </div>
            <div class="box-body">
                <div class="chart" style="width: 100%; height: 180px">
                    <canvas id="clientsChart" class="no-user-select"></canvas>
                </div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="box" id="query-types-pie">
            <div class="box-header with-border">
                <h3 class="box-title">Query Types</h3>
            </div>
            <div class="box-body">
                <div style="width:50%">
                    <canvas id="queryTypePieChart" width="280" height="280"></canvas>
                </div>
                <div class="chart-legend" style="width:50%" id="query-types-legend" ></div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
    </div>
    <div class="col-md-6">
        <div class="box" id="forward-destinations-pie">
            <div class="box-header with-border">
                <h3 class="box-title">Upstream servers</h3>
            </div>
            <div class="box-body">
                <div style="width:50%">
                    <canvas id="forwardDestinationPieChart" width="280" height="280" class="no-user-select"></canvas>
                </div>
                <div class="chart-legend" style="width:50%" id="forward-destinations-legend"></div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
    </div>
</div>

<? if pihole.boxedlayout() then tablelayout = 'col-md-6' else  tablelayout = 'col-md-6 col-lg-6' end ?>
<div class="row">
    <div class="<?=tablelayout?>">
        <div class="box" id="domain-frequency">
            <div class="box-header with-border">
                <h3 class="box-title">Top Permitted Domains</h3>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                            <th>Domain</th>
                            <th>Hits</th>
                            <th>Frequency</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
        <!-- /.box -->
    </div>
    <!-- /.col -->
    <div class="<?=tablelayout?>">
        <div class="box" id="ad-frequency">
            <div class="box-header with-border">
                <h3 class="box-title">Top Blocked Domains</h3>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                            <th>Domain</th>
                            <th>Hits</th>
                            <th>Frequency</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
        <!-- /.box -->
    </div>
</div>
<div class="row">
    <!-- /.col -->
    <div class="<?=tablelayout?>">
        <div class="box" id="client-frequency">
            <div class="box-header with-border">
                <h3 class="box-title">Top Clients (total)</h3>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                            <th>Client</th>
                            <th>Requests</th>
                            <th>Frequency</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
        <!-- /.box -->
    </div>
    <!-- /.col -->
    <div class="<?=tablelayout?>">
        <div class="box" id="client-frequency-blocked">
            <div class="box-header with-border">
                <h3 class="box-title">Top Clients (blocked only)</h3>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                            <th>Client</th>
                            <th>Requests</th>
                            <th>Frequency</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="overlay">
                <i class="fa fa-sync fa-spin"></i>
            </div>
            <!-- /.box-body -->
        </div>
        <!-- /.box -->
    </div>
    <!-- /.col -->
</div>
<!-- /.row -->

<script src="<?=pihole.fileversion('scripts/js/charts.js')?>"></script>
<script src="<?=pihole.fileversion('scripts/js/index.js')?>"></script>

<? mg.include('scripts/lua/footer.lp','r')?>
